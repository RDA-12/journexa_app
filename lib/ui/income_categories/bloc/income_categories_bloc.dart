import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
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
@injectable
class IncomeCategoriesBloc
    extends Bloc<IncomeCategoriesEvent, IncomeCategoriesState>
    with Loggable, GenerateUid {
  /// Creates new [IncomeCategoriesBloc]
  new({
    required this._watchIncomeCategories,
    required this._deleteIncomeCategory,
    required this._updateIncomeCategory,
  }) : super(const IncomeCategoriesState()) {
    on<_SubscriptionRequested>(
      (event, emit) async {
        return await _onSubscriptionRequested(
          emit: emit,
          params: WatchIncomeCategoriesParams(query: event.query),
        );
      },
      transformer: debounce(),
    );
    on<_Delete>(
      (event, emit) async {
        return await _onDelete(category: event.category, emit: emit);
      },
    );
    on<_Update>(
      (event, emit) async {
        return await _onUpdate(
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
            logInfo(
              'Streamed income categories succeeded. Emit loaded status',
              traceId: traceId,
            );
            return state.copyWith(
              status: IncomeCategoriesUIStatus.loaded,
              categories: categories,
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
      (it) => it.id == category.id,
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
      'Emit new deletingIds with category id',
      traceId: traceId,
    );
    emit(
      state.copyWith(
        deletingIds: Set.from(state.deletingIds)..add(category.id),
      ),
    );
    final result = await _deleteIncomeCategory.execute(
      DeleteIncomeCategoryParams(category: category),
      traceId: traceId,
    );
    final notice = result.when(
      success: (_) {
        logInfo(
          'Deletes category success. '
          'Remove ID from deletingIds '
          'Emit with recentlyDeleted notice',
          traceId: traceId,
        );
        return IncomeCategoryUINotice.recentlyDeleted(category: category);
      },
      failure: (exc) {
        logInfo(
          'Delete category failed. '
          'Emit removed ID from deletingIds with deleteFailed notice',
          traceId: traceId,
        );
        return IncomeCategoryUINotice.deleteFailed(
          category: category,
          exception: exc,
        );
      },
    );
    emit(
      state.copyWith(
        deletingIds: Set.from(state.deletingIds)..remove(category.id),
        notice: notice,
      ),
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
      (it) => it.id == category.id,
    );
    if (categoryIdx == -1) {
      logInfo('IncomeCategory not found. Skipping', traceId: traceId);
      return;
    }
    final oldIncomeCategory = state.categories[categoryIdx];

    logInfo(
      'Starts updating category ${category.id}. '
      'Emit new updatingIds with category id',
      traceId: traceId,
    );
    emit(
      state.copyWith(
        updatingIds: Set.from(state.updatingIds)..add(category.id),
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
    final notice = result.when(
      success: (updated) {
        logInfo(
          'Updates category success. '
          'Emit removed ID from updatingIds and recentlyUpdated notice',
          traceId: traceId,
        );
        return IncomeCategoryUINotice.recentlyUpdated(
          from: oldIncomeCategory,
          to: updated,
        );
      },
      failure: (exc) {
        logInfo(
          'Update category failed. '
          'Emit removed ID from updatingIds and updateFailed notice',
          traceId: traceId,
        );
        return IncomeCategoryUINotice.updateFailed(
          category: category,
          exception: exc,
        );
      },
    );
    emit(
      state.copyWith(
        updatingIds: Set.from(state.updatingIds)..remove(category.id),
        notice: notice,
      ),
    );
  }
}
