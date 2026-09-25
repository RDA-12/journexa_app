part of 'expense_categories_bloc.dart';

/// Status of [ExpenseCategoriesBloc]
///
/// Specifically for load and search events
enum ExpenseCategoriesUIStatus {
  /// Initial status
  initial,

  /// Loading status for load and search event
  loading,

  /// Success status
  loaded,

  /// Failure status for load and search event
  failure,
}


/// Class meant to be used as notice of [ExpenseCategoriesBloc]
///
/// This class can be used as notice to show any notice to UI
@freezed
sealed class ExpenseCategoryUINotice with _$ExpenseCategoryUINotice {
  /// Creates new [ExpenseCategoryUINotice] as deleted notice
  const factory recentlyDeleted({
    /// The [ExpenseCategory] that was recently deleted
    required ExpenseCategory category,
  }) = _ExpenseCategoryUINoticeRecentlyDeleted;

  /// Creates new [ExpenseCategoryUINotice] as updated notice
  const factory recentlyUpdated({
    /// Old [ExpenseCategory]
    required ExpenseCategory from,

    /// New updated [ExpenseCategory]
    required ExpenseCategory to,
  }) = _ExpenseCategoryUINoticeRecentlyUpdated;

  /// Creates new [ExpenseCategoryUINotice] as delete failed notice
  const factory deleteFailed({
    /// [ExpenseCategory] that meant to be deleted
    required ExpenseCategory category,

    /// Exception that occurred when delete event failed
    required AppException exception,
  }) = _ExpenseCategoryUINoticeDeleteFailed;

  /// Creates new [ExpenseCategoryUINotice] as update failed notice
  const factory updateFailed({
    /// [ExpenseCategory] that meant to be updated
    required ExpenseCategory category,

    /// Exception that occurred when update event failed
    required AppException exception,
  }) = _ExpenseCategoryUINoticeUpdateFailed;
}

/// States of [ExpenseCategoriesBloc]
@freezed
sealed class ExpenseCategoriesState with _$ExpenseCategoriesState {
  /// Creates new [ExpenseCategoriesState]
  const factory({
    /// Status of the state
    @Default(ExpenseCategoriesUIStatus.initial)
    ExpenseCategoriesUIStatus status,

    /// List of expense categories
    @Default([]) List<ExpenseCategory> categories,

    /// Exception that occurred when load or search event failed
    AppException? exception,

    /// Notice that meant to be announce by UI
    ExpenseCategoryUINotice? notice,

    /// Set of ids that in the middle of deleting process
    @Default({}) Set<String> deletingIds,

    /// Set of ids that in the middle of updating process
    @Default({}) Set<String> updatingIds,
  }) = _ExpenseCategoriesState;

  const new _();
}
