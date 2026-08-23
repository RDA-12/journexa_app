part of 'income_categories_bloc.dart';

/// Status of [IncomeCategoriesBloc]
///
/// Specifically for load and search events
enum IncomeCategoriesStatus {
  /// Initial status
  initial,

  /// Loading status for load and search event
  loading,

  /// Success status
  loaded,

  /// Failure status for load and search event
  failure,
}

/// Status for [IncomeCategoryWithState]
enum IncomeCategoryStatus {
  /// Idle status
  idle,

  /// Status when delete event is in process
  deleting,

  /// Status when update event is in process
  updating,
}

/// Class meant to be used as notice of [IncomeCategoriesBloc]
///
/// This class can be used as notice to show any notice to UI
@freezed
sealed class IncomeCategoryNotice with _$IncomeCategoryNotice {
  /// Creates new [IncomeCategoryNotice] as deleted notice
  const factory IncomeCategoryNotice.recentlyDeleted({
    /// The [IncomeCategory] that was recently deleted
    required IncomeCategory category,
  }) = _IncomeCategoryNoticeRecentlyDeleted;

  /// Creates new [IncomeCategoryNotice] as updated notice
  const factory IncomeCategoryNotice.recentlyUpdated({
    /// Old [IncomeCategory]
    required IncomeCategory from,

    /// New updated [IncomeCategory]
    required IncomeCategory to,
  }) = _IncomeCategoryNoticeRecentlyUpdated;

  /// Creates new [IncomeCategoryNotice] as delete failed notice
  const factory IncomeCategoryNotice.deleteFailed({
    /// [IncomeCategory] that meant to be deleted
    required IncomeCategory category,

    /// Exception that occurred when delete event failed
    required AppException exception,
  }) = _IncomeCategoryNoticeDeleteFailed;

  /// Creates new [IncomeCategoryNotice] as update failed notice
  const factory IncomeCategoryNotice.updateFailed({
    /// [IncomeCategory] that meant to be updated
    required IncomeCategory category,

    /// Exception that occurred when update event failed
    required AppException exception,
  }) = _IncomeCategoryNoticeUpdateFailed;
}

/// Extends [IncomeCategory] to includes state for UI
@freezed
sealed class IncomeCategoryWithState with _$IncomeCategoryWithState {
  const factory IncomeCategoryWithState({
    /// The [IncomeCategory]
    required IncomeCategory category,

    /// Status for UI
    @Default(IncomeCategoryStatus.idle) IncomeCategoryStatus status,
  }) = _IncomeCategoryWithState;
}

/// States of [IncomeCategoriesBloc]
@freezed
sealed class IncomeCategoriesState with _$IncomeCategoriesState {
  /// Creates new [IncomeCategoriesState]
  const factory IncomeCategoriesState({
    /// Status of the state
    @Default(IncomeCategoriesStatus.initial) IncomeCategoriesStatus status,

    /// List of income categories with their balances
    @Default([]) List<IncomeCategoryWithState> categories,

    /// Exception that occurred when load or search event failed
    AppException? exception,

    /// Notice that meant to be announce by UI
    IncomeCategoryNotice? notice,
  }) = _IncomeCategoriesState;

  const IncomeCategoriesState._();
}
