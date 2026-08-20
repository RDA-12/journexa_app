part of 'wallets_bloc.dart';

/// Status of [WalletsBloc]
enum WalletsStatus {
  /// Initial status
  initial,

  /// Loading status for load and search event
  loading,

  /// Success status
  loaded,

  /// Failure status for load and search event
  failure,

  /// Failure status for delete event
  deleteFailure,

  /// Failure status for update event
  updateFailure,
}

/// Extends [AccountBalance] to includes state for UI
@freezed
sealed class AccountBalanceWithState with _$AccountBalanceWithState {
  const factory AccountBalanceWithState({
    /// The [AccountBalance]
    required AccountBalance accountBalance,

    /// Whether this [AccountBalance] is in deleting process or not
    @Default(false) bool isDeleting,

    /// Whether this [AccountBalance] is in updating process or not
    @Default(false) bool isUpdating,
  }) = _AccountBalanceWithState;
}

/// States of [WalletsBloc]
@freezed
sealed class WalletsState with _$WalletsState {
  /// Creates new [WalletsState]
  const factory WalletsState({
    /// Status of the state
    @Default(WalletsStatus.initial) WalletsStatus status,

    /// List of wallets with their balances
    @Default([]) List<AccountBalanceWithState> accountBalances,

    /// Recently deleted [Account]
    Account? recentlyDeletedAccount,

    /// Recently updated [Account]
    Account? recentlyUpdatedAccount,

    /// Exception that occurred when load or search event failed
    AppException? exception,

    /// Exception that occurred when delete event failed
    AppException? deleteException,

    /// Exception that occurred when update event failed
    AppException? updateException,
  }) = _WalletsState;

  const WalletsState._();
}
