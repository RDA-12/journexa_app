part of 'cash_accounts_bloc.dart';

/// Events for [CashAccountsBloc]
@freezed
class CashAccountsEvent with _$CashAccountsEvent {
  /// Event to loading cash accounts
  const factory CashAccountsEvent.load() = _Load;
}
