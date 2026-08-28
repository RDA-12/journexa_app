import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
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

    /// Amount of income the [wallet] gets
    required Decimal amount,

    /// Date when the transaction happened
    required DateTime date,

    /// Notes or description
    String? notes,
  }) = IncomeTransaction;
  Transaction._() {
    if (amount <= Decimal.zero) {
      throw AppException(
        'amount must be positive. Got: $amount',
        code: AppExceptionCode.internalException,
      );
    }
  }

  /// Creates new [Transaction] for test purposes
  factory Transaction.test({
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
}
