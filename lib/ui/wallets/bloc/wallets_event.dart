part of 'wallets_bloc.dart';

/// Events for [WalletsBloc]
@freezed
sealed class WalletsEvent with _$WalletsEvent {
  /// Request to start listen to [WalletWithBalance] streams
  const factory WalletsEvent.subscriptionRequested({String? query}) =
      _SubscriptionRequested;

  /// Event to delete [wallet]
  const factory WalletsEvent.delete(Wallet wallet) = _Delete;

  /// Event to update [wallet] based on provided arguments
  const factory WalletsEvent.update(
    Wallet wallet, {
    String? name,
  }) = _Update;
}
