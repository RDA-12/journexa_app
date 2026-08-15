part of 'cash_accounts_bloc.dart';

/// States of [CashAccountsBloc]
@freezed
class CashAccountsState with _$CashAccountsState {
  /// Intitial state
  const factory CashAccountsState.initial() = _Initial;

  /// State when loading data
  const factory CashAccountsState.loading() = _Loading;

  /// States when data loaded
  const factory CashAccountsState.loaded(List<AccountBalance> accountBalances) =
      _Loaded;

  /// States when laoding data failed
  const factory CashAccountsState.failure(AppException exc) = _Failure;
}
