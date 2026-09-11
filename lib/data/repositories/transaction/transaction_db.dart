import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:journexa_app/data/converter.dart';
import 'package:journexa_app/data/database.dart';
import 'package:journexa_app/data/repositories/expense_category/expense_category.dart';
import 'package:journexa_app/data/repositories/income_category/income_category.dart';
import 'package:journexa_app/data/repositories/wallet/wallet.dart';
import 'package:journexa_app/domain/entities/transaction.dart';

/// Local table for [Transaction]
class TransactionDB extends Table {
  /// Unique ID of this [Transaction]
  late final Column<String> id = text()();

  /// Type of this [Transaction]
  late final Column<String> type = text()();

  /// Amount of this [Transaction]
  late final Column<String> amount = text().map(
    const DriftDecimalConverter(),
  )();

  /// Date when this [Transaction] occurred
  late final Column<String> date = text().map(
    const DriftDateTimeConverter(),
  )();

  /// Optional notes of this [Transaction]
  late final Column<String> notes = text().nullable()();

  /// Wallet ID for income and expense transactions
  @ReferenceName('tr_wallet_ref')
  late final Column<String>? walletId = text().nullable().references(
    WalletDB,
    #id,
  )();

  /// Income category ID for income transactions
  late final Column<String>? incomeCategoryId = text().nullable().references(
    IncomeCategoryDB,
    #id,
  )();

  /// Expense category ID for expense transactions
  late final Column<String>? expenseCategoryId = text().nullable().references(
    ExpenseCategoryDB,
    #id,
  )();

  /// Source wallet ID for transfer transactions
  @ReferenceName('tr_source_wallet_ref')
  late final Column<String>? sourceWalletId = text().nullable().references(
    WalletDB,
    #id,
  )();

  /// Destination wallet ID for transfer transactions
  @ReferenceName('tr_destination_wallet_ref')
  late final Column<String>? destinationWalletId = text().nullable().references(
    WalletDB,
    #id,
  )();

  /// Fee for transfer transactions
  late final Column<String> fee = text()
      .map(
        const DriftDecimalConverter(),
      )
      .nullable()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

/// Extension to provide helpers on [TransactionDBData]
extension TransactionDBDataX on TransactionDBData {
  /// Return [Transaction] from this [TransactionDBData]
  Transaction toDomain() {
    final transactionType = TransactionType.values.byName(type);
    switch (transactionType) {
      case TransactionType.income:
        return Transaction.income(
          id: id,
          walletId: walletId!,
          incomeCategoryId: incomeCategoryId!,
          amount: amount,
          date: date,
          notes: notes,
        );
      case TransactionType.expense:
        return Transaction.expense(
          id: id,
          walletId: walletId!,
          expenseCategoryId: expenseCategoryId!,
          amount: amount,
          date: date,
          notes: notes,
        );
      case TransactionType.transfer:
        return Transaction.transfer(
          id: id,
          sourceWalletId: sourceWalletId!,
          destinationWalletId: destinationWalletId!,
          amount: amount,
          fee: fee ?? Decimal.zero,
          date: date,
          notes: notes,
        );
    }
  }
}

/// Extension to provide helpers on [Transaction]
extension TransactionX on Transaction {
  /// Return [TransactionDBCompanion] from this [Transaction]
  TransactionDBCompanion toDB() {
    return when(
      income: (id, walletId, categoryId, amount, date, notes) {
        return TransactionDBCompanion.insert(
          id: id,
          type: TransactionType.income.name,
          amount: amount,
          date: date,
          notes: Value(notes),
          walletId: Value(walletId),
          incomeCategoryId: Value(categoryId),
        );
      },
      expense: (id, walletId, categoryId, amount, date, notes) {
        return TransactionDBCompanion.insert(
          id: id,
          type: TransactionType.expense.name,
          amount: amount,
          date: date,
          notes: Value(notes),
          walletId: Value(walletId),
          expenseCategoryId: Value(categoryId),
        );
      },
      transfer:
          (
            id,
            sourceWalletId,
            destinationWalletId,
            amount,
            fee,
            date,
            notes,
          ) {
            return TransactionDBCompanion.insert(
              id: id,
              type: TransactionType.transfer.name,
              amount: amount,
              date: date,
              notes: Value(notes),
              sourceWalletId: Value(sourceWalletId),
              destinationWalletId: Value(destinationWalletId),
              fee: Value(fee),
            );
          },
    );
  }
}
