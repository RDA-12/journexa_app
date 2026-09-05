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

/// Status for [ExpenseCategoryUIModel]
enum ExpenseCategoryUIStatus {
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
sealed class ExpenseCategoryUINotice with _$ExpenseCategoryUINotice {
  /// Creates new [ExpenseCategoryUINotice] as deleted notice
  const factory ExpenseCategoryUINotice.recentlyDeleted({
    /// The [ExpenseCategory] that was recently deleted
    required ExpenseCategory category,
  }) = _ExpenseCategoryUINoticeRecentlyDeleted;

  /// Creates new [ExpenseCategoryUINotice] as updated notice
  const factory ExpenseCategoryUINotice.recentlyUpdated({
    /// Old [ExpenseCategory]
    required ExpenseCategory from,

    /// New updated [ExpenseCategory]
    required ExpenseCategory to,
  }) = _ExpenseCategoryUINoticeRecentlyUpdated;

  /// Creates new [ExpenseCategoryUINotice] as delete failed notice
  const factory ExpenseCategoryUINotice.deleteFailed({
    /// [ExpenseCategory] that meant to be deleted
    required ExpenseCategory category,

    /// Exception that occurred when delete event failed
    required AppException exception,
  }) = _ExpenseCategoryUINoticeDeleteFailed;

  /// Creates new [ExpenseCategoryUINotice] as update failed notice
  const factory ExpenseCategoryUINotice.updateFailed({
    /// [ExpenseCategory] that meant to be updated
    required ExpenseCategory category,

    /// Exception that occurred when update event failed
    required AppException exception,
  }) = _ExpenseCategoryUINoticeUpdateFailed;
}

/// Extends [ExpenseCategory] to includes state for UI
@freezed
sealed class ExpenseCategoryUIModel with _$ExpenseCategoryUIModel {
  const factory ExpenseCategoryUIModel({
    /// The [ExpenseCategory]
    required ExpenseCategory category,

    /// Status for UI
    @Default(ExpenseCategoryUIStatus.idle) ExpenseCategoryUIStatus status,
  }) = _ExpenseCategoryUIModel;
}

/// States of [ExpenseCategoriesBloc]
@freezed
sealed class ExpenseCategoriesState with _$ExpenseCategoriesState {
  /// Creates new [ExpenseCategoriesState]
  const factory ExpenseCategoriesState({
    /// Status of the state
    @Default(ExpenseCategoriesUIStatus.initial)
    ExpenseCategoriesUIStatus status,

    /// List of expense categories with their balances
    @Default([]) List<ExpenseCategoryUIModel> categories,

    /// Exception that occurred when load or search event failed
    AppException? exception,

    /// Notice that meant to be announce by UI
    ExpenseCategoryUINotice? notice,
  }) = _ExpenseCategoriesState;

  const ExpenseCategoriesState._();
}
