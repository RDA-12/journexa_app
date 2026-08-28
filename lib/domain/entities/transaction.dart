import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:journexa_app/domain/entities/expense_category.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/shared/app_exception.dart';

part 'transaction.freezed.dart';

/// Represent single transaction
@freezed
sealed class Transaction with _$Transaction {
  /// Creates new [IncomeTransaction]
  factory Transaction.income({
    /// Unique ID of this transaction
    required String id,

    /// [Wallet] to put the [amount]
    required Wallet wallet,

    /// [IncomeCategory] of this transaction
    required IncomeCategory category,

    /// Amount of money the wallet gets
    required Decimal amount,

    /// Date when the transaction happened
    required DateTime date,

    /// Notes or description
    String? notes,
  }) = IncomeTransaction;

  /// Creates new [ExpenseTransaction]
  factory Transaction.expense({
    /// Unique ID of this transaction
    required String id,

    /// [Wallet] to put the [amount]
    required Wallet wallet,

    /// [ExpenseCategory] of this transaction
    required ExpenseCategory category,

    /// Amount of money the wallet needs to spend
    required Decimal amount,

    /// Date when the transaction happened
    required DateTime date,

    /// Notes or description
    String? notes,
  }) = ExpenseTransaction;

  /// Creates new [TransferTransaction]
  factory Transaction.transfer({
    /// Unique ID of this transaction
    required String id,

    /// Source [Wallet] of this transaction
    required Wallet source,

    /// Destination [Wallet] of this transaction
    required Wallet destination,

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

  Transaction._() {
    if (amount <= Decimal.zero) {
      throw AppException(
        'amount must be positive. Got: $amount',
        code: AppExceptionCode.internalException,
      );
    }
    whenOrNull(
      transfer: (id, source, destination, amount, fee, date, notes) {
        if (source == destination) {
          throw AppException(
            'source and destination wallet must be different. '
            'Got: ${source.id} and ${destination.id}',
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
  factory Transaction.testIncome({
    required Decimal amount,
    required DateTime date,
  }) {
    return Transaction.income(
      id: 'id',
      wallet: Wallet.test(),
      category: IncomeCategory.test(),
      amount: amount,
      date: date,
      notes: 'Test income',
    );
  }

  /// Creates new [ExpenseTransaction] for test purposes
  factory Transaction.testExpense({
    required Decimal amount,
    required DateTime date,
  }) {
    return Transaction.expense(
      id: 'id',
      wallet: Wallet.test(),
      category: ExpenseCategory.test(),
      amount: amount,
      date: date,
      notes: 'Test expense',
    );
  }

  /// Creates new [TransferTransaction] for test purposes
  factory Transaction.testTransfer({
    required Decimal amount,
    required DateTime date,
    required Decimal fee,
  }) {
    return Transaction.transfer(
      id: 'id',
      source: Wallet.test(),
      destination: Wallet.test().update(name: 'wallet 2').copyWith(id: 'id-2'),
      amount: amount,
      fee: fee,
      date: date,
      notes: 'Test transfer',
    );
  }
}
