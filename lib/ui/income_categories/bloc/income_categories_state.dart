part of 'income_categories_bloc.dart';

/// Status of [IncomeCategoriesBloc]
///
/// Specifically for load and search events
enum IncomeCategoriesUIStatus {
  /// Initial status
  initial,

  /// Loading status for load and search event
  loading,

  /// Success status
  loaded,

  /// Failure status for load and search event
  failure,
}

/// Status for [IncomeCategoryUIModel]
enum IncomeCategoryUIStatus {
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
sealed class IncomeCategoryUINotice with _$IncomeCategoryUINotice {
  /// Creates new [IncomeCategoryUINotice] as deleted notice
  const factory recentlyDeleted({
    /// The [IncomeCategory] that was recently deleted
    required IncomeCategory category,
  }) = _IncomeCategoryUINoticeRecentlyDeleted;

  /// Creates new [IncomeCategoryUINotice] as updated notice
  const factory recentlyUpdated({
    /// Old [IncomeCategory]
    required IncomeCategory from,

    /// New updated [IncomeCategory]
    required IncomeCategory to,
  }) = _IncomeCategoryUINoticeRecentlyUpdated;

  /// Creates new [IncomeCategoryUINotice] as delete failed notice
  const factory deleteFailed({
    /// [IncomeCategory] that meant to be deleted
    required IncomeCategory category,

    /// Exception that occurred when delete event failed
    required AppException exception,
  }) = _IncomeCategoryUINoticeDeleteFailed;

  /// Creates new [IncomeCategoryUINotice] as update failed notice
  const factory updateFailed({
    /// [IncomeCategory] that meant to be updated
    required IncomeCategory category,

    /// Exception that occurred when update event failed
    required AppException exception,
  }) = _IncomeCategoryUINoticeUpdateFailed;
}

/// Extends [IncomeCategory] to includes state for UI
@freezed
sealed class IncomeCategoryUIModel with _$IncomeCategoryUIModel {
  const factory({
    /// The [IncomeCategory]
    required IncomeCategory category,

    /// Status for UI
    @Default(IncomeCategoryUIStatus.idle) IncomeCategoryUIStatus status,
  }) = _IncomeCategoryUIModel;
}

/// States of [IncomeCategoriesBloc]
@freezed
sealed class IncomeCategoriesState with _$IncomeCategoriesState {
  /// Creates new [IncomeCategoriesState]
  const factory({
    /// Status of the state
    @Default(IncomeCategoriesUIStatus.initial) IncomeCategoriesUIStatus status,

    /// List of income categories with their balances
    @Default([]) List<IncomeCategoryUIModel> categories,

    /// Exception that occurred when load or search event failed
    AppException? exception,

    /// Notice that meant to be announce by UI
    IncomeCategoryUINotice? notice,
  }) = _IncomeCategoriesState;

  const new _();
}
