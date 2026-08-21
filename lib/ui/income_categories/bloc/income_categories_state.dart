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

/// Status for [AccountWithState]
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
    /// The [Account] that was recently deleted
    required Account account,
  }) = _IncomeCategoryNoticeRecentlyDeleted;

  /// Creates new [IncomeCategoryNotice] as updated notice
  const factory IncomeCategoryNotice.recentlyUpdated({
    /// Old [Account]
    required Account from,

    /// New updated [Account]
    required Account to,
  }) = _IncomeCategoryNoticeRecentlyUpdated;

  /// Creates new [IncomeCategoryNotice] as delete failed notice
  const factory IncomeCategoryNotice.deleteFailed({
    /// [Account] that meant to be deleted
    required Account account,

    /// Exception that occurred when delete event failed
    required AppException exception,
  }) = _IncomeCategoryNoticeDeleteFailed;

  /// Creates new [IncomeCategoryNotice] as update failed notice
  const factory IncomeCategoryNotice.updateFailed({
    /// [Account] that meant to be updated
    required Account account,

    /// Exception that occurred when update event failed
    required AppException exception,
  }) = _IncomeCategoryNoticeUpdateFailed;
}

/// Extends [Account] to includes state for UI
@freezed
sealed class AccountWithState with _$AccountWithState {
  const factory AccountWithState({
    /// The [Account]
    required Account account,

    /// Status for UI
    @Default(IncomeCategoryStatus.idle) IncomeCategoryStatus status,
  }) = _AccountWithState;
}

/// States of [IncomeCategoriesBloc]
@freezed
sealed class IncomeCategoriesState with _$IncomeCategoriesState {
  /// Creates new [IncomeCategoriesState]
  const factory IncomeCategoriesState({
    /// Status of the state
    @Default(IncomeCategoriesStatus.initial) IncomeCategoriesStatus status,

    /// List of wallets with their balances
    @Default([]) List<AccountWithState> accounts,

    /// Exception that occurred when load or search event failed
    AppException? exception,

    /// Notice that meant to be announce by UI
    IncomeCategoryNotice? notice,
  }) = _IncomeCategoriesState;

  const IncomeCategoriesState._();
}
