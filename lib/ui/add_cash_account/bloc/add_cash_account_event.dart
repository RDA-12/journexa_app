part of 'add_cash_account_bloc.dart';

/// Events for [AddCashAccountBloc]
@freezed
sealed class AddCashAccountEvent with _$AddCashAccountEvent {
  /// Submit to creates new cash account with [name]
  const factory AddCashAccountEvent.submit({required String name}) = _Started;
}
