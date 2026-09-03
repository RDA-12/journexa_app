import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:journexa_app/shared/json_converter/decimal_converter.dart';

part 'firestore_transaction.freezed.dart';
part 'firestore_transaction.g.dart';

/// Firestore representation of [Transaction]
@Freezed(unionKey: 'type')
sealed class FirestoreTransaction with _$FirestoreTransaction {
  const FirestoreTransaction._();

  /// Creates new [FirestoreTransaction] representing
  /// [IncomeTransaction]
  @FreezedUnionValue('income')
  const factory FirestoreTransaction.income({
    /// ID of the transaction
    required String id,

    /// Wallet to holds the amount value
    required String walletId,

    /// Income category for this transaction
    required String incomeCategoryId,

    /// Amount the income has
    @DecimalConverter() required Decimal amount,

    /// When the transaction happened
    required DateTime date,

    /// optional notes
    String? notes,
  }) = FirestoreIncomeTransaction;

  /// Creates new [FirestoreTransaction] representing
  /// [ExpenseTransaction]
  @FreezedUnionValue('expense')
  const factory FirestoreTransaction.expense({
    /// ID of the transaction
    required String id,

    /// Wallet to holds the amount value
    required String walletId,

    /// Expense category for this transaction
    required String expenseCategoryId,

    /// Amount the income has
    @DecimalConverter() required Decimal amount,

    /// When the transaction happened
    required DateTime date,

    /// optional notes
    String? notes,
  }) = FirestoreExpenseTransaction;

  /// Creates new [FirestoreTransaction] representing
  /// [TransferTransaction]
  @FreezedUnionValue('transfer')
  const factory FirestoreTransaction.transfer({
    /// ID of the transaction
    required String id,

    /// Source wallet of this transaction
    required String sourceWalletId,

    /// Destination wallet of this transaction
    required String destinationWalletId,

    /// Amount to be transfered
    @DecimalConverter() required Decimal amount,

    /// Fee of this transaction
    @DecimalConverter() required Decimal fee,

    /// Date when the transaction happened
    required DateTime date,

    /// optional notes
    String? notes,
  }) = FirestoreTransferTransaction;

  /// Creates new [FirestoreTransaction] from [json]
  ///
  /// It will map based on type in [json]
  factory FirestoreTransaction.fromJson(Map<String, Object?> json) =>
      _$FirestoreTransactionFromJson(json);

  /// Creates new [FirestoreTransaction] from [Transaction]
  factory FirestoreTransaction.fromDomain(Transaction transaction) {
    return transaction.when(
      income: (id, walletId, categoryId, amount, date, notes) {
        return FirestoreTransaction.income(
          id: id,
          walletId: walletId,
          incomeCategoryId: categoryId,
          amount: amount,
          date: date,
          notes: notes,
        );
      },
      expense: (id, walletId, categoryId, amount, date, notes) {
        return FirestoreTransaction.expense(
          id: id,
          walletId: walletId,
          expenseCategoryId: categoryId,
          amount: amount,
          date: date,
          notes: notes,
        );
      },
      transfer:
          (id, sourceWalletId, destinationWalletId, amount, fee, date, notes) {
            return FirestoreTransaction.transfer(
              id: id,
              sourceWalletId: sourceWalletId,
              destinationWalletId: destinationWalletId,
              amount: amount,
              fee: fee,
              date: date,
              notes: notes,
            );
          },
    );
  }

  Transaction toModel() {
    return when(
      income: (id, walletId, incomeCategoryId, amount, date, notes) =>
          IncomeTransaction(
            id: id,
            walletId: walletId,
            incomeCategoryId: incomeCategoryId,
            amount: amount,
            date: date,
            notes: notes,
          ),
      expense: (id, walletId, expenseCategoryId, amount, date, notes) =>
          ExpenseTransaction(
            id: id,
            walletId: walletId,
            expenseCategoryId: expenseCategoryId,
            amount: amount,
            date: date,
            notes: notes,
          ),
      transfer:
          (id, sourceWalletId, destinationWalletId, amount, fee, date, notes) {
            return TransferTransaction(
              id: id,
              sourceWalletId: sourceWalletId,
              destinationWalletId: destinationWalletId,
              amount: amount,
              fee: fee,
              date: date,
              notes: notes,
            );
          },
    );
  }
}
