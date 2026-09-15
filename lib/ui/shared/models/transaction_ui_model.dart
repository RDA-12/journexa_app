import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:journexa_app/domain/entities/expense_category.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:journexa_app/domain/entities/wallet.dart';

part 'transaction_ui_model.freezed.dart';

/// Represent [Transaction] model for UI
@freezed
sealed class TransactionUIModel with _$TransactionUIModel {
  /// Creates new [IncomeTransaction]
  factory income({
    /// Unique ID of this transaction
    required String id,

    /// [Wallet] the [amount] will be added to it
    required Wallet wallet,

    /// [IncomeCategory] this transaction belongs to
    required IncomeCategory category,

    /// Amount of money the wallet gets
    required Decimal amount,

    /// Date when the transaction happened
    required DateTime date,

    /// Notes or description
    String? notes,
  }) = _IncomeTransactionUIModel;

  /// Creates new [ExpenseTransaction]
  factory expense({
    /// Unique ID of this transaction
    required String id,

    /// [Wallet] the [amount] will be deducted from it
    required Wallet wallet,

    /// [ExpenseCategory] this transaction belongs to
    required ExpenseCategory category,

    /// Amount of money the wallet needs to spend
    required Decimal amount,

    /// Date when the transaction happened
    required DateTime date,

    /// Notes or description
    String? notes,
  }) = _ExpenseTransactionUIModel;

  /// Creates new [TransferTransaction]
  factory transfer({
    /// Unique ID of this transaction
    required String id,

    /// [Wallet] the [amount] will be deducted from it
    required Wallet sourceWallet,

    /// [Wallet] the [amount] will be added to it
    required Wallet destinationWallet,

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
  }) = _TransferTransactionUIModel;
}
