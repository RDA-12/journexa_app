import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:journexa_app/shared/app_exception.dart';

part 'transaction.freezed.dart';

/// Types of [Transaction]
enum TransactionType {
  /// Income type
  income,

  /// Expense type
  expense,

  /// Transfer type
  transfer,
}

/// Represent single transaction
@freezed
sealed class Transaction with _$Transaction {
  /// Creates new [IncomeTransaction]
  factory income({
    /// Unique ID of this transaction
    required String id,

    /// ID of the Wallet to put the [amount]
    required String walletId,

    /// ID of the IncomeCategory
    required String incomeCategoryId,

    /// Amount of money the wallet gets
    required Decimal amount,

    /// Date when the transaction happened
    required DateTime date,

    /// Notes or description
    String? notes,
  }) = IncomeTransaction;

  /// Creates new [ExpenseTransaction]
  factory expense({
    /// Unique ID of this transaction
    required String id,

    /// ID of the Wallet to spend the [amount]
    required String walletId,

    /// ID of the ExpenseCategory
    required String expenseCategoryId,

    /// Amount of money the wallet needs to spend
    required Decimal amount,

    /// Date when the transaction happened
    required DateTime date,

    /// Notes or description
    String? notes,
  }) = ExpenseTransaction;

  /// Creates new [TransferTransaction]
  factory transfer({
    /// Unique ID of this transaction
    required String id,

    /// ID of the Source Wallet
    required String sourceWalletId,

    /// ID of the Destination Wallet
    required String destinationWalletId,

    /// Amount of money that will be transfered
    /// from source to destination wallet
    required Decimal amount,

    /// Transfer fee
    ///
    /// Fee that will be deducted from source wallet.
    required Decimal fee,

    /// Date when the transaction happened
    required DateTime date,

    /// Notes or description
    String? notes,
  }) = TransferTransaction;

  new _() {
    if (amount <= Decimal.zero) {
      throw AppException(
        'amount must be positive. Got: $amount',
        code: AppExceptionCode.internalException,
      );
    }
    whenOrNull(
      transfer:
          (id, sourceWalletId, destinationWalletId, amount, fee, date, notes) {
            if (sourceWalletId == destinationWalletId) {
              throw AppException(
                'source and destination wallet must be different. '
                'Got: $sourceWalletId and $destinationWalletId',
                code: AppExceptionCode.internalException,
              );
            }
            if (fee < Decimal.zero) {
              throw AppException(
                'fee must be 0 or positive. Got: $fee',
                code: AppExceptionCode.internalException,
              );
            }
          },
    );
  }

  /// Creates new [IncomeTransaction] for test purposes
  factory testIncome({
    required Decimal amount,
    required DateTime date,
  }) {
    return Transaction.income(
      id: 'id',
      walletId: 'walletId',
      incomeCategoryId: 'incomeCategoryId',
      amount: amount,
      date: date,
      notes: 'Test income',
    );
  }

  /// Creates new [ExpenseTransaction] for test purposes
  factory testExpense({
    required Decimal amount,
    required DateTime date,
  }) {
    return Transaction.expense(
      id: 'id',
      walletId: 'walletId',
      expenseCategoryId: 'expenseCategoryId',
      amount: amount,
      date: date,
      notes: 'Test expense',
    );
  }

  /// Creates new [TransferTransaction] for test purposes
  factory testTransfer({
    required Decimal amount,
    required DateTime date,
    required Decimal fee,
  }) {
    return Transaction.transfer(
      id: 'id',
      sourceWalletId: 'sourceWalletId',
      destinationWalletId: 'destinationWalletId',
      amount: amount,
      fee: fee,
      date: date,
      notes: 'Test transfer',
    );
  }
}
