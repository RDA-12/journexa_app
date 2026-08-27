part of 'expense_categories_bloc.dart';

/// Status of [ExpenseCategoriesBloc]
///
/// Specifically for load and search events
enum ExpenseCategoriesStatus {
  /// Initial status
  initial,

  /// Loading status for load and search event
  loading,

  /// Success status
  loaded,

  /// Failure status for load and search event
  failure,
}

/// Status for [ExpenseCategoryWithState]
enum ExpenseCategoryStatus {
  /// Idle status
  idle,

  /// Status when delete event is in process
  deleting,

  /// Status when update event is in process
  updating,
}

/// Class meant to be used as notice of [ExpenseCategoriesBloc]
///
/// This class can be used as notice to show any notice to UI
@freezed
sealed class ExpenseCategoryNotice with _$ExpenseCategoryNotice {
  /// Creates new [ExpenseCategoryNotice] as deleted notice
  const factory ExpenseCategoryNotice.recentlyDeleted({
    /// The [ExpenseCategory] that was recently deleted
    required ExpenseCategory category,
  }) = _ExpenseCategoryNoticeRecentlyDeleted;

  /// Creates new [ExpenseCategoryNotice] as updated notice
  const factory ExpenseCategoryNotice.recentlyUpdated({
    /// Old [ExpenseCategory]
    required ExpenseCategory from,

    /// New updated [ExpenseCategory]
    required ExpenseCategory to,
  }) = _ExpenseCategoryNoticeRecentlyUpdated;

  /// Creates new [ExpenseCategoryNotice] as delete failed notice
  const factory ExpenseCategoryNotice.deleteFailed({
    /// [ExpenseCategory] that meant to be deleted
    required ExpenseCategory category,

    /// Exception that occurred when delete event failed
    required AppException exception,
  }) = _ExpenseCategoryNoticeDeleteFailed;

  /// Creates new [ExpenseCategoryNotice] as update failed notice
  const factory ExpenseCategoryNotice.updateFailed({
    /// [ExpenseCategory] that meant to be updated
    required ExpenseCategory category,

    /// Exception that occurred when update event failed
    required AppException exception,
  }) = _ExpenseCategoryNoticeUpdateFailed;
}

/// Extends [ExpenseCategory] to includes state for UI
@freezed
sealed class ExpenseCategoryWithState with _$ExpenseCategoryWithState {
  const factory ExpenseCategoryWithState({
    /// The [ExpenseCategory]
    required ExpenseCategory category,

    /// Status for UI
    @Default(ExpenseCategoryStatus.idle) ExpenseCategoryStatus status,
  }) = _ExpenseCategoryWithState;
}

/// States of [ExpenseCategoriesBloc]
@freezed
sealed class ExpenseCategoriesState with _$ExpenseCategoriesState {
  /// Creates new [ExpenseCategoriesState]
  const factory ExpenseCategoriesState({
    /// Status of the state
    @Default(ExpenseCategoriesStatus.initial) ExpenseCategoriesStatus status,

    /// List of expense categories with their balances
    @Default([]) List<ExpenseCategoryWithState> categories,

    /// Exception that occurred when load or search event failed
    AppException? exception,

    /// Notice that meant to be announce by UI
    ExpenseCategoryNotice? notice,
  }) = _ExpenseCategoriesState;

  const ExpenseCategoriesState._();
}
