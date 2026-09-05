import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/domain/use_cases/income_category/delete_income_category.dart';
import 'package:journexa_app/domain/use_cases/income_category/update_income_category.dart';
import 'package:journexa_app/domain/use_cases/income_category/watch_income_categories.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';
import 'package:journexa_app/ui/shared/event_transform/debounce.dart';

part 'income_categories_bloc.freezed.dart';
part 'income_categories_event.dart';
part 'income_categories_state.dart';

/// Bloc to handle income categories
class IncomeCategoriesBloc
    extends Bloc<IncomeCategoriesEvent, IncomeCategoriesState>
    with Loggable, GenerateUid {
  /// Creates new [IncomeCategoriesBloc]
  IncomeCategoriesBloc({
    required this._watchIncomeCategories,
    required this._deleteIncomeCategory,
    required this._updateIncomeCategory,
  }) : super(const IncomeCategoriesState()) {
    on<_SubscriptionRequested>(
      (event, emit) async {
        return _onSubscriptionRequested(
          emit: emit,
          params: WatchIncomeCategoriesParams(query: event.query),
        );
      },
      transformer: debounce(),
    );
    on<_Delete>(
      (event, emit) async {
        return _onDelete(category: event.category, emit: emit);
      },
    );
    on<_Update>(
      (event, emit) async {
        return _onUpdate(
          category: event.category,
          emit: emit,
          name: event.name,
        );
      },
    );
  }

  @override
  String get logTag => 'IncomeCategoriesBloc';

  final WatchIncomeCategoriesUseCase _watchIncomeCategories;
  final UpdateIncomeCategoryUseCase _updateIncomeCategory;
  final DeleteIncomeCategoryUseCase _deleteIncomeCategory;

  Future<void> _onSubscriptionRequested({
    required Emitter<IncomeCategoriesState> emit,
    required WatchIncomeCategoriesParams params,
  }) async {
    final traceId = generateUid();
    logInfo(
      'Starts listening to IncomeCategory streams. '
      'Emits loading state',
      traceId: traceId,
    );
    emit(
      const IncomeCategoriesState(
        status: IncomeCategoriesUIStatus.loading,
      ),
    );

    final stream = _watchIncomeCategories.execute(
      params,
      traceId: traceId,
    );
    await emit.forEach(
      stream,
      onData: (result) {
        return result.when(
          success: (categories) {
            final currentItemState = {
              for (final it in state.categories) it.category.id: it.status,
            };
            logInfo(
              'Streamed income categories succeeded. Emit loaded status',
              traceId: traceId,
            );
            return state.copyWith(
              status: IncomeCategoriesUIStatus.loaded,
              categories: categories
                  .map(
                    (it) => IncomeCategoryUIModel(
                      category: it,
                      status:
                          currentItemState[it.id] ??
                          IncomeCategoryUIStatus.idle,
                    ),
                  )
                  .toList(),
            );
          },
          failure: (exc) {
            logInfo(
              'Streamed income categories failed. Emit failure status',
              traceId: traceId,
            );
            return state.copyWith(
              status: IncomeCategoriesUIStatus.failure,
              exception: exc,
            );
          },
        );
      },
    );
  }

  Future<void> _onDelete({
    required IncomeCategory category,
    required Emitter<IncomeCategoriesState> emit,
  }) async {
    final traceId = generateUid();
    final categoryIdx = state.categories.indexWhere(
      (it) => it.category.id == category.id,
    );
    if (categoryIdx == -1) {
      logInfo(
        'IncomeCategory with id ${category.id} not found in categories. '
        'Early return',
        traceId: traceId,
      );
      return;
    }

    logInfo(
      'Starts deleting category with id ${category.id}. '
      'Emit new categories with status deleting on the IncomeCategory',
      traceId: traceId,
    );
    emit(
      state.copyWith(
        categories: state.categories.map((it) {
          final isDeleting = it.category.id == category.id;
          if (!isDeleting) return it;
          return it.copyWith(status: IncomeCategoryUIStatus.deleting);
        }).toList(),
      ),
    );
    final result = await _deleteIncomeCategory.execute(
      DeleteIncomeCategoryParams(category: category),
      traceId: traceId,
    );
    result.when(
      success: (_) {
        logInfo(
          'Deletes category success. '
          'Filter category from categories. '
          'Emit with recentlyDeleted notice',
          traceId: traceId,
        );
        emit(
          state.copyWith(
            status: IncomeCategoriesUIStatus.loaded,
            notice: IncomeCategoryUINotice.recentlyDeleted(category: category),
          ),
        );
      },
      failure: (exc) {
        logInfo(
          'Delete category failed. '
          'Emit idle status on the IncomeCategory with deleteFailed notice',
          traceId: traceId,
        );
        emit(
          state.copyWith(
            status: IncomeCategoriesUIStatus.loaded,
            categories: state.categories.map((it) {
              final processed = it.category.id == category.id;
              if (!processed) return it;
              return it.copyWith(status: IncomeCategoryUIStatus.idle);
            }).toList(),
            notice: IncomeCategoryUINotice.deleteFailed(
              category: category,
              exception: exc,
            ),
          ),
        );
      },
    );
  }

  Future<void> _onUpdate({
    required IncomeCategory category,
    required Emitter<IncomeCategoriesState> emit,
    String? name,
  }) async {
    final traceId = generateUid();
    logInfo('Checking category with id ${category.id}', traceId: traceId);
    final categoryIdx = state.categories.indexWhere(
      (it) => it.category.id == category.id,
    );
    if (categoryIdx == -1) {
      logInfo('IncomeCategory not found. Skipping', traceId: traceId);
      return;
    }
    final oldIncomeCategory = state.categories[categoryIdx].category;

    logInfo(
      'Starts updating category ${category.id}. '
      'Emit new categories with status updateing on the IncomeCategory',
      traceId: traceId,
    );
    emit(
      state.copyWith(
        categories: state.categories.map((it) {
          final isUpdating = it.category.id == category.id;
          if (!isUpdating) return it;
          return it.copyWith(status: IncomeCategoryUIStatus.updating);
        }).toList(),
      ),
    );

    final params = UpdateIncomeCategoryParams(
      category: category,
      name: name,
    );
    final result = await _updateIncomeCategory.execute(
      params,
      traceId: traceId,
    );
    result.when(
      success: (updated) {
        logInfo(
          'Updates category success. '
          'Emit updated category with idle status and recentlyUpdated notice',
          traceId: traceId,
        );
        emit(
          state.copyWith(
            status: IncomeCategoriesUIStatus.loaded,
            notice: IncomeCategoryUINotice.recentlyUpdated(
              from: oldIncomeCategory,
              to: updated,
            ),
          ),
        );
      },
      failure: (exc) {
        logInfo(
          'Update category failed. '
          'Emit idle status on the IncomeCategory and updateFailed notice',
          traceId: traceId,
        );
        emit(
          state.copyWith(
            status: IncomeCategoriesUIStatus.loaded,
            categories: state.categories.map((it) {
              final processed = it.category.id == category.id;
              if (!processed) return it;
              return it.copyWith(
                status: IncomeCategoryUIStatus.idle,
              );
            }).toList(),
            notice: IncomeCategoryUINotice.updateFailed(
              category: category,
              exception: exc,
            ),
          ),
        );
      },
    );
  }
}
