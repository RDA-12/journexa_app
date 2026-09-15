part of 'add_wallet_bloc.dart';

/// States of [AddWalletBloc]
@freezed
class AddWalletState with _$AddWalletState {
  /// Initial state
  const factory initial() = _Initial;

  /// State when the new account is being added
  const factory loading() = _Loading;

  /// State when new account is successfully added
  const factory added() = _Added;

  /// State when fails to add new wallet
  const factory failure(
    AppException exc, {
    String? name,
  }) = _Failure;
}
