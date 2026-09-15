part of 'wallets_bloc.dart';

/// Events for [WalletsBloc]
@freezed
sealed class WalletsEvent with _$WalletsEvent {
  /// Request to start listen to [Wallet] and its balance stream
  const factory subscriptionRequested({String? query}) =
      _SubscriptionRequested;

  /// Event to delete [wallet]
  const factory delete(Wallet wallet) = _Delete;

  /// Event to update [wallet] based on provided arguments
  const factory update(
    Wallet wallet, {
    String? name,
  }) = _Update;
}
