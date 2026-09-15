part of 'add_transaction_bloc.dart';

/// Notice state to be included when [Transaction] is added successfully.
@freezed
sealed class TransactionAddedNotice with _$TransactionAddedNotice {
  /// Creates [TransactionAddedNotice] for transfer transaction.
  const factory transferAdded({
    required Wallet source,
    required Wallet destination,
    required Decimal amount,
  }) = _TransferAddedNotice;

  /// Creates [TransactionAddedNotice] for income transaction.
  const factory incomeAdded({
    required Wallet wallet,
    required IncomeCategory category,
    required Decimal amount,
  }) = _IncomeAddedNotice;

  /// Creates [TransactionAddedNotice] for expense transaction.
  const factory expenseAdded({
    required Wallet wallet,
    required ExpenseCategory category,
    required Decimal amount,
  }) = _ExpenseAddedNotice;
}

/// State for [AddTransactionBloc]
@freezed
class AddTransactionState with _$AddTransactionState {
  /// Intiial state
  const factory initial() = _Initial;

  /// State when transaction is being added
  const factory loading() = _Loading;

  /// State when transaction is added successfully
  const factory added(TransactionAddedNotice notice) =
      _Added;

  /// State when transaction is added with error
  const factory failure(AppException error) = _Failure;
}
