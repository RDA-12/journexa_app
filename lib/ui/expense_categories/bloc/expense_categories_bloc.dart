import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/entities/expense_category.dart';
import 'package:journexa_app/domain/use_cases/expense_category/delete_expense_category.dart';
import 'package:journexa_app/domain/use_cases/expense_category/update_expense_category.dart';
import 'package:journexa_app/domain/use_cases/expense_category/watch_expense_categories.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';
import 'package:journexa_app/ui/shared/event_transform/debounce.dart';

part 'expense_categories_bloc.freezed.dart';
part 'expense_categories_event.dart';
part 'expense_categories_state.dart';

/// Bloc to handle expense categories
@injectable
class ExpenseCategoriesBloc
    extends Bloc<ExpenseCategoriesEvent, ExpenseCategoriesState>
    with Loggable, GenerateUid {
  /// Creates new [ExpenseCategoriesBloc]
  new({
    required this._watchExpenseCategories,
    required this._deleteExpenseCategory,
    required this._updateExpenseCategory,
  }) : super(const ExpenseCategoriesState()) {
    on<_SubscriptionRequested>(
      (event, emit) async {
        return await _onSubscriptionRequested(
          emit: emit,
          params: WatchExpenseCategoriesParams(query: event.query),
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
  String get logTag => 'ExpenseCategoriesBloc';

  final WatchExpenseCategoriesUseCase _watchExpenseCategories;
  final UpdateExpenseCategoryUseCase _updateExpenseCategory;
  final DeleteExpenseCategoryUseCase _deleteExpenseCategory;

  Future<void> _onSubscriptionRequested({
    required Emitter<ExpenseCategoriesState> emit,
    required WatchExpenseCategoriesParams params,
  }) async {
    final traceId = generateUid();
    logInfo(
      'Starts listening to ExpenseCategory streams. '
      'Emits loading state',
      traceId: traceId,
    );
    emit(
      const ExpenseCategoriesState(
        status: ExpenseCategoriesUIStatus.loading,
      ),
    );

    final stream = _watchExpenseCategories.execute(
      params,
      traceId: traceId,
    );
    await emit.forEach(
      stream,
      onData: (result) {
        return result.when(
          success: (categories) {
            logInfo(
              'Streamed expense categories succeeded. Emit loaded status',
              traceId: traceId,
            );
            return state.copyWith(
              status: ExpenseCategoriesUIStatus.loaded,
              categories: categories,
            );
          },
          failure: (exc) {
            logInfo(
              'Streamed expense categories failed. Emit failure status',
              traceId: traceId,
            );
            return state.copyWith(
              status: ExpenseCategoriesUIStatus.failure,
              exception: exc,
            );
          },
        );
      },
    );
  }

  Future<void> _onDelete({
    required ExpenseCategory category,
    required Emitter<ExpenseCategoriesState> emit,
  }) async {
    final traceId = generateUid();
    final categoryIdx = state.categories.indexWhere(
      (it) => it.id == category.id,
    );
    if (categoryIdx == -1) {
      logInfo(
        'ExpenseCategory with id ${category.id} not found in categories. '
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
    final result = await _deleteExpenseCategory.execute(
      DeleteExpenseCategoryParams(category: category),
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
        return ExpenseCategoryUINotice.recentlyDeleted(category: category);
      },
      failure: (exc) {
        logInfo(
          'Delete category failed. '
          'Emit removed ID from deletingIds with deleteFailed notice',
          traceId: traceId,
        );
        return ExpenseCategoryUINotice.deleteFailed(
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
    required ExpenseCategory category,
    required Emitter<ExpenseCategoriesState> emit,
    String? name,
  }) async {
    final traceId = generateUid();
    logInfo('Checking category with id ${category.id}', traceId: traceId);
    final categoryIdx = state.categories.indexWhere(
      (it) => it.id == category.id,
    );
    if (categoryIdx == -1) {
      logInfo('ExpenseCategory not found. Skipping', traceId: traceId);
      return;
    }
    final oldExpenseCategory = state.categories[categoryIdx];

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

    final params = UpdateExpenseCategoryParams(
      category: category,
      name: name,
    );
    final result = await _updateExpenseCategory.execute(
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
        return ExpenseCategoryUINotice.recentlyUpdated(
          from: oldExpenseCategory,
          to: updated,
        );
      },
      failure: (exc) {
        logInfo(
          'Update category failed. '
          'Emit removed ID from updatingIds and updateFailed notice',
          traceId: traceId,
        );
        return ExpenseCategoryUINotice.updateFailed(
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
