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

  /// Loading status for delete event
  deleting,

  /// Failure status for delete event
  deleteFailure,
}

/// States of [CashAccountsBloc]
@freezed
sealed class CashAccountsState with _$CashAccountsState {
  /// Creates new [CashAccountsState]
  const factory CashAccountsState({
    /// Status of the state
    @Default(CashAccountsStatus.initial) CashAccountsStatus status,

    /// List of cash accounts with their balances
    @Default([]) List<AccountBalance> accountBalances,

    /// Exception that occurred when load or search event failed
    AppException? exception,

    /// Exception that occurred when delete event failed
    AppException? deleteException,
  }) = _CashAccountsState;

  const CashAccountsState._();
}
