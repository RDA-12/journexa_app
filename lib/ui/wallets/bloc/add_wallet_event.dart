part of 'add_wallet_bloc.dart';

/// Events for [AddWalletBloc]
@freezed
sealed class AddWalletEvent with _$AddWalletEvent {
  /// Submit to creates new wallet with [name]
  const factory submit({required String name}) = _Started;
}
