part of 'add_transaction_bloc.dart';

/// Events for [AddTransactionBloc]
@freezed
sealed class AddTransactionEvent with _$AddTransactionEvent {
  /// Event to add a transfer transaction
  const factory AddTransactionEvent.transfer({
    required Wallet source,
    required Wallet destination,
    required Decimal amount,
    required Decimal fee,
    required DateTime date,
    String? notes,
  }) = _Transfer;

  /// Event to add an income transaction
  const factory AddTransactionEvent.income({
    required Wallet wallet,
    required IncomeCategory category,
    required Decimal amount,
    required DateTime date,
    String? notes,
  }) = _Income;

  /// Event to add an expense transaction
  const factory AddTransactionEvent.expense({
    required Wallet wallet,
    required ExpenseCategory category,
    required Decimal amount,
    required DateTime date,
    String? notes,
  }) = _Expense;
}
