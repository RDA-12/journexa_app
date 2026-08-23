import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/domain/use_cases/account/delete_account.dart';
import 'package:journexa_app/domain/use_cases/account/update_account.dart';
import 'package:journexa_app/domain/use_cases/income_category/get_all_income_categories.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';
import 'package:journexa_app/ui/shared/event_transform/debounce.dart';

part 'income_categories_event.dart';
part 'income_categories_state.dart';
part 'income_categories_bloc.freezed.dart';

/// Bloc to handle income categories
class IncomeCategoriesBloc
    extends Bloc<IncomeCategoriesEvent, IncomeCategoriesState>
    with Loggable, GenerateUid {
  /// Creates new [IncomeCategoriesBloc]
  IncomeCategoriesBloc({
    required this._getAllIncomeCategories,
    required this._deleteIncomeCategory,
    required this._updateIncomeCategory,
  }) : super(const IncomeCategoriesState()) {
    on<_Load>((event, emit) async {
      return _onLoad(
        emit: emit,
        params: const GetAllIncomeCategoriesParams(),
      );
    });
    on<_Search>(
      (event, emit) async {
        return _onLoad(
          emit: emit,
          params: GetAllIncomeCategoriesParams(query: event.query),
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

  final GetAllIncomeCategoriesUseCase _getAllIncomeCategories;
  final UpdateAccountUseCase _updateIncomeCategory;
  final DeleteAccountUseCase _deleteIncomeCategory;

  Future<void> _onLoad({
    required Emitter<IncomeCategoriesState> emit,
    required GetAllIncomeCategoriesParams params,
  }) async {
    final traceId = generateUid();
    logInfo(
      'Starts getting income categories for current user. '
      'Emit loading status',
      traceId: traceId,
    );
    emit(state.copyWith(status: IncomeCategoriesStatus.loading));

    final result = await _getAllIncomeCategories.execute(
      params,
      traceId: traceId,
    );
    result.when(
      success: (categories) {
        logInfo(
          'Get income categories succeeded. Emit loaded status',
          traceId: traceId,
        );
        emit(
          state.copyWith(
            status: IncomeCategoriesStatus.loaded,
            categories: categories
                .map((it) => IncomeCategoryWithState(category: it))
                .toList(),
          ),
        );
      },
      failure: (exc) {
        logInfo(
          'Get income categories failed. Emit failure status',
          traceId: traceId,
        );
        emit(
          state.copyWith(
            status: IncomeCategoriesStatus.failure,
            exception: exc,
          ),
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
          return it.copyWith(status: IncomeCategoryStatus.deleting);
        }).toList(),
      ),
    );
    final result = await _deleteIncomeCategory.execute(
      DeleteAccountParams(account: category.account),
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
            status: IncomeCategoriesStatus.loaded,
            categories: state.categories
                .where((it) => it.category.id != category.id)
                .toList(),
            notice: IncomeCategoryNotice.recentlyDeleted(category: category),
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
            status: IncomeCategoriesStatus.loaded,
            categories: state.categories.map((it) {
              final processed = it.category.id == category.id;
              if (!processed) return it;
              return it.copyWith(status: IncomeCategoryStatus.idle);
            }).toList(),
            notice: IncomeCategoryNotice.deleteFailed(
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
          return it.copyWith(status: IncomeCategoryStatus.updating);
        }).toList(),
      ),
    );

    final params = UpdateAccountParams(
      code: category.account.code,
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
            status: IncomeCategoriesStatus.loaded,
            categories: state.categories.map((it) {
              final processed = it.category.id == category.id;
              if (!processed) return it;
              return it.copyWith(
                status: IncomeCategoryStatus.idle,
                category: it.category.copyWith(
                  name: params.name ?? category.name,
                  account: updated,
                ),
              );
            }).toList(),
            notice: IncomeCategoryNotice.recentlyUpdated(
              from: oldIncomeCategory,
              to: category.copyWith(
                name: params.name ?? category.name,
                account: updated,
              ),
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
            status: IncomeCategoriesStatus.loaded,
            categories: state.categories.map((it) {
              final processed = it.category.id == category.id;
              if (!processed) return it;
              return it.copyWith(
                status: IncomeCategoryStatus.idle,
              );
            }).toList(),
            notice: IncomeCategoryNotice.updateFailed(
              category: category,
              exception: exc,
            ),
          ),
        );
      },
    );
  }
}
