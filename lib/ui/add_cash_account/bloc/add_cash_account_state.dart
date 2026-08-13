part of 'add_cash_account_bloc.dart';

/// States of [AddCashAccountBloc]
@freezed
class AddCashAccountState with _$AddCashAccountState {
  /// Initial state
  const factory AddCashAccountState.initial() = _Initial;

  /// State when the new account is being added
  const factory AddCashAccountState.loading() = _Loading;

  /// State when new account is successfully added
  const factory AddCashAccountState.added() = _Added;

  /// State when fails to add new cash account
  const factory AddCashAccountState.failure(AppException exc) = _Failure;
}
