part of 'transactions_bloc.dart';

/// States for [TransactionsBloc]
@freezed
sealed class TransactionsState with _$TransactionsState {
  /// Initial state
  const factory initial() = _Initial;

  /// State when transactions is loading
  const factory loading() = _Loading;

  /// State when transactions has been loaded
  const factory loaded(
    List<TransactionUIModel> transactions,
  ) = _Loaded;

  /// State when failed to fetch transactions
  const factory failure(AppException exception) = _Failure;
}
