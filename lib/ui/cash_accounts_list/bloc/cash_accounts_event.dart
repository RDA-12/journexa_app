part of 'cash_accounts_bloc.dart';

/// Events for [CashAccountsBloc]
@freezed
sealed class CashAccountsEvent with _$CashAccountsEvent {
  /// Event to loading cash accounts
  const factory CashAccountsEvent.load() = _Load;

  /// event to search for cash accounts
  ///
  /// It uses debounce transformer to prevent rapid calls
  const factory CashAccountsEvent.search({String? query}) = _Search;
}
