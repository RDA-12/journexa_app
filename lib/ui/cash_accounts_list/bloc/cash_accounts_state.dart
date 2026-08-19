part of 'cash_accounts_bloc.dart';

/// Status of [CashAccountsBloc]
enum CashAccountsStatus {
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

/// States of [CashAccountsBloc]
@freezed
sealed class CashAccountsState with _$CashAccountsState {
  /// Creates new [CashAccountsState]
  const factory CashAccountsState({
    /// Status of the state
    @Default(CashAccountsStatus.initial) CashAccountsStatus status,

    /// List of cash accounts with their balances
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
  }) = _CashAccountsState;

  const CashAccountsState._();
}
