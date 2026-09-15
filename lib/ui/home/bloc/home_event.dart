part of 'home_bloc.dart';

/// Events for [HomeBloc]
@freezed
class HomeEvent with _$HomeEvent {
  /// Event to trigger subscriptions to wallets data
  const factory walletsSubscriptionRequested() =
      _WalletsSubscriptionRequested;

  /// Event to trigger to subscribe to mtd data
  const factory mtdSubscriptionRequested({
    required DateTime targetDate,
    Wallet? wallet,
  }) = _MTDSubscriptionRequested;

  /// Event to trigger subscriptions to transactions data
  const factory transactionsSubscriptionRequested({
    Wallet? wallet,
  }) = _TransactionsSubscriptionRequested;
}
