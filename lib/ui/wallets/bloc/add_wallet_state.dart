part of 'add_wallet_bloc.dart';

/// States of [AddWalletBloc]
@freezed
class AddWalletState with _$AddWalletState {
  /// Initial state
  const factory AddWalletState.initial() = _Initial;

  /// State when the new account is being added
  const factory AddWalletState.loading() = _Loading;

  /// State when new account is successfully added
  const factory AddWalletState.added() = _Added;

  /// State when fails to add new wallet
  const factory AddWalletState.failure(AppException exc) = _Failure;
}
