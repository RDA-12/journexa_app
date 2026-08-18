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
}

/// Extends [AccountBalance] to includes state for UI
@freezed
sealed class AccountBalanceWithState with _$AccountBalanceWithState {
  const factory AccountBalanceWithState({
    /// The [AccountBalance]
    required AccountBalance accountBalance,

    /// Whether this [AccountBalance] is in deleting process or not
    @Default(false) bool isDeleting,
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

    /// Exception that occurred when load or search event failed
    AppException? exception,

    /// Exception that occurred when delete event failed
    AppException? deleteException,
  }) = _CashAccountsState;

  const CashAccountsState._();
}
