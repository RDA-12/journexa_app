part of 'transactions_bloc.dart';

/// States for [TransactionsBloc]
@freezed
sealed class TransactionsState with _$TransactionsState {
  /// Initial state
  const factory TransactionsState.initial() = _Initial;

  /// State when transactions is loading
  const factory TransactionsState.loading() = _Loading;

  /// State when transactions has been loaded
  const factory TransactionsState.loaded(
    List<TransactionUIModel> transactions,
  ) = _Loaded;

  /// State when failed to fetch transactions
  const factory TransactionsState.failure(AppException exception) = _Failure;
}
