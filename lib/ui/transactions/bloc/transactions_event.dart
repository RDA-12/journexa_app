part of 'transactions_bloc.dart';

/// Events for [TransactionsBloc]
@freezed
sealed class TransactionsEvent with _$TransactionsEvent {
  /// Request to subscribe to [Transaction] stream
  const factory subscriptionRequested() = _SubscriptionRequested;
}
