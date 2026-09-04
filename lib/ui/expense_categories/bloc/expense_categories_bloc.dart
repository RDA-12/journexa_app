import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
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
class ExpenseCategoriesBloc
    extends Bloc<ExpenseCategoriesEvent, ExpenseCategoriesState>
    with Loggable, GenerateUid {
  /// Creates new [ExpenseCategoriesBloc]
  ExpenseCategoriesBloc({
    required this._watchExpenseCategories,
    required this._deleteExpenseCategory,
    required this._updateExpenseCategory,
  }) : super(const ExpenseCategoriesState()) {
    on<_SubscriptionRequested>(
      (event, emit) async {
        return _onSubscriptionRequested(
          emit: emit,
          params: WatchExpenseCategoriesParams(query: event.query),
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
        status: ExpenseCategoriesStatus.loading,
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
            final currentItemState = {
              for (final it in state.categories) it.category.id: it.status,
            };
            logInfo(
              'Streamed expense categories succeeded. Emit loaded status',
              traceId: traceId,
            );
            return state.copyWith(
              status: ExpenseCategoriesStatus.loaded,
              categories: categories
                  .map(
                    (it) => ExpenseCategoryWithState(
                      category: it,
                      status:
                          currentItemState[it.id] ?? ExpenseCategoryStatus.idle,
                    ),
                  )
                  .toList(),
            );
          },
          failure: (exc) {
            logInfo(
              'Streamed expense categories failed. Emit failure status',
              traceId: traceId,
            );
            return state.copyWith(
              status: ExpenseCategoriesStatus.failure,
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
      (it) => it.category.id == category.id,
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
      'Emit new categories with status deleting on the ExpenseCategory',
      traceId: traceId,
    );
    emit(
      state.copyWith(
        categories: state.categories.map((it) {
          final isDeleting = it.category.id == category.id;
          if (!isDeleting) return it;
          return it.copyWith(status: ExpenseCategoryStatus.deleting);
        }).toList(),
      ),
    );
    final result = await _deleteExpenseCategory.execute(
      DeleteExpenseCategoryParams(category: category),
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
            status: ExpenseCategoriesStatus.loaded,
            notice: ExpenseCategoryNotice.recentlyDeleted(category: category),
          ),
        );
      },
      failure: (exc) {
        logInfo(
          'Delete category failed. '
          'Emit idle status on the ExpenseCategory with deleteFailed notice',
          traceId: traceId,
        );
        emit(
          state.copyWith(
            status: ExpenseCategoriesStatus.loaded,
            categories: state.categories.map((it) {
              final processed = it.category.id == category.id;
              if (!processed) return it;
              return it.copyWith(status: ExpenseCategoryStatus.idle);
            }).toList(),
            notice: ExpenseCategoryNotice.deleteFailed(
              category: category,
              exception: exc,
            ),
          ),
        );
      },
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
      (it) => it.category.id == category.id,
    );
    if (categoryIdx == -1) {
      logInfo('ExpenseCategory not found. Skipping', traceId: traceId);
      return;
    }
    final oldExpenseCategory = state.categories[categoryIdx].category;

    logInfo(
      'Starts updating category ${category.id}. '
      'Emit new categories with status updating on the ExpenseCategory',
      traceId: traceId,
    );
    emit(
      state.copyWith(
        categories: state.categories.map((it) {
          final isUpdating = it.category.id == category.id;
          if (!isUpdating) return it;
          return it.copyWith(status: ExpenseCategoryStatus.updating);
        }).toList(),
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
    result.when(
      success: (updated) {
        logInfo(
          'Updates category success. '
          'Emit updated category with idle status and recentlyUpdated notice',
          traceId: traceId,
        );
        emit(
          state.copyWith(
            status: ExpenseCategoriesStatus.loaded,
            notice: ExpenseCategoryNotice.recentlyUpdated(
              from: oldExpenseCategory,
              to: updated,
            ),
          ),
        );
      },
      failure: (exc) {
        logInfo(
          'Update category failed. '
          'Emit idle status on the ExpenseCategory and updateFailed notice',
          traceId: traceId,
        );
        emit(
          state.copyWith(
            status: ExpenseCategoriesStatus.loaded,
            categories: state.categories.map((it) {
              final processed = it.category.id == category.id;
              if (!processed) return it;
              return it.copyWith(
                status: ExpenseCategoryStatus.idle,
              );
            }).toList(),
            notice: ExpenseCategoryNotice.updateFailed(
              category: category,
              exception: exc,
            ),
          ),
        );
      },
    );
  }
}
