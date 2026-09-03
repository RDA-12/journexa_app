import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/data/repositories/transaction/firestore_transaction.dart';
import 'package:journexa_app/domain/entities/transaction.dart';

void main() {
  group('FirestoreTransaction.fromDomain', () {
    final date = DateTime.now();
    test('returns correct transaction for income', () {
      final income = IncomeTransaction(
        id: 'id',
        walletId: 'wallet-1',
        incomeCategoryId: 'income-1',
        amount: Decimal.fromInt(100),
        date: date,
        notes: 'Test income',
      );
      final expected = FirestoreIncomeTransaction(
        id: income.id,
        $type: 'income',
        walletId: 'wallet-1',
        incomeCategoryId: 'income-1',
        amount: income.amount,
        date: date,
        notes: 'Test income',
      );

      final actual = FirestoreTransaction.fromDomain(income);

      expect(actual, expected);
    });

    test('returns correct transaction for expense', () {
      final expense = ExpenseTransaction(
        id: 'id',
        walletId: 'wallet-1',
        expenseCategoryId: 'expense-1',
        amount: Decimal.fromInt(100),
        date: date,
        notes: 'Test expense',
      );
      final expected = FirestoreExpenseTransaction(
        id: expense.id,
        $type: 'expense',
        walletId: 'wallet-1',
        expenseCategoryId: 'expense-1',
        amount: Decimal.fromInt(100),
        date: date,
        notes: 'Test expense',
      );

      final actual = FirestoreTransaction.fromDomain(expense);

      expect(actual, expected);
    });

    test('returns correct transaction for transfer', () {
      final transfer = TransferTransaction(
        id: 'id',
        sourceWalletId: 'wallet-1',
        destinationWalletId: 'wallet-2',
        amount: Decimal.fromInt(100),
        fee: Decimal.fromInt(10),
        date: date,
        notes: 'Test transfer',
      );
      final expected = FirestoreTransferTransaction(
        id: transfer.id,
        $type: 'transfer',
        sourceWalletId: 'wallet-1',
        destinationWalletId: 'wallet-2',
        amount: Decimal.fromInt(100),
        fee: Decimal.fromInt(10),
        date: date,
        notes: 'Test transfer',
      );

      final actual = FirestoreTransaction.fromDomain(transfer);

      expect(actual, expected);
    });
  });

  group('FirestoreTransaction.toModel', () {
    final date = DateTime.now();
    test('returns correct transaction for income', () {
      final income = FirestoreIncomeTransaction(
        id: 'id',
        $type: 'income',
        walletId: 'wallet-1',
        incomeCategoryId: 'income-1',
        amount: Decimal.fromInt(100),
        date: date,
        notes: 'Test income',
      );
      final expected = IncomeTransaction(
        id: 'id',
        walletId: 'wallet-1',
        incomeCategoryId: 'income-1',
        amount: Decimal.fromInt(100),
        date: date,
        notes: 'Test income',
      );

      final actual = income.toModel();

      expect(actual, expected);
    });

    test('returns correct transaction for expense', () {
      final expense = FirestoreExpenseTransaction(
        id: 'id',
        $type: 'expense',
        walletId: 'wallet-1',
        expenseCategoryId: 'expense-1',
        amount: Decimal.fromInt(100),
        date: date,
        notes: 'Test expense',
      );
      final expected = ExpenseTransaction(
        id: 'id',
        walletId: 'wallet-1',
        expenseCategoryId: 'expense-1',
        amount: Decimal.fromInt(100),
        date: date,
        notes: 'Test expense',
      );

      final actual = expense.toModel();

      expect(actual, expected);
    });

    test('returns correct transaction for transfer', () {
      final transfer = FirestoreTransferTransaction(
        id: 'id',
        $type: 'transfer',
        sourceWalletId: 'wallet-1',
        destinationWalletId: 'wallet-2',
        amount: Decimal.fromInt(100),
        fee: Decimal.fromInt(10),
        date: date,
        notes: 'Test transfer',
      );
      final expected = TransferTransaction(
        id: 'id',
        sourceWalletId: 'wallet-1',
        destinationWalletId: 'wallet-2',
        amount: Decimal.fromInt(100),
        fee: Decimal.fromInt(10),
        date: date,
        notes: 'Test transfer',
      );

      final actual = transfer.toModel();

      expect(actual, expected);
    });
  });
}
