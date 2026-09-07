import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/data/database.dart';
import 'package:journexa_app/data/repositories/transaction/transaction.dart';
import 'package:journexa_app/domain/entities/transaction.dart';

void main() {
  final testDate = DateTime(2026, 9, 7, 12);
  final testAmount = Decimal.fromInt(100);
  final testFee = Decimal.fromInt(5);

  group('TransactionDBData.toDomain', () {
    test('returns correct IncomeTransaction', () {
      final dbData = TransactionDBData(
        id: 'inc-1',
        type: TransactionType.income.name,
        amount: testAmount,
        date: testDate,
        notes: 'Income note',
        walletId: 'wallet-1',
        incomeCategoryId: 'income-cat-1',
      );

      final expected = Transaction.income(
        id: 'inc-1',
        walletId: 'wallet-1',
        incomeCategoryId: 'income-cat-1',
        amount: testAmount,
        date: testDate,
        notes: 'Income note',
      );

      expect(dbData.toDomain(), expected);
    });

    test('returns correct ExpenseTransaction', () {
      final dbData = TransactionDBData(
        id: 'exp-1',
        type: TransactionType.expense.name,
        amount: testAmount,
        date: testDate,
        notes: 'Expense note',
        walletId: 'wallet-1',
        expenseCategoryId: 'expense-cat-1',
      );

      final expected = Transaction.expense(
        id: 'exp-1',
        walletId: 'wallet-1',
        expenseCategoryId: 'expense-cat-1',
        amount: testAmount,
        date: testDate,
        notes: 'Expense note',
      );

      expect(dbData.toDomain(), expected);
    });

    test('returns correct TransferTransaction', () {
      final dbData = TransactionDBData(
        id: 'trans-1',
        type: TransactionType.transfer.name,
        amount: testAmount,
        fee: testFee,
        date: testDate,
        notes: 'Transfer note',
        sourceWalletId: 'wallet-src',
        destinationWalletId: 'wallet-dst',
      );

      final expected = Transaction.transfer(
        id: 'trans-1',
        sourceWalletId: 'wallet-src',
        destinationWalletId: 'wallet-dst',
        amount: testAmount,
        fee: testFee,
        date: testDate,
        notes: 'Transfer note',
      );

      expect(dbData.toDomain(), expected);
    });
  });

  group('Transaction.toDB', () {
    test('returns correct TransactionDBCompanion for IncomeTransaction', () {
      final domain = Transaction.income(
        id: 'inc-1',
        walletId: 'wallet-1',
        incomeCategoryId: 'income-cat-1',
        amount: testAmount,
        date: testDate,
        notes: 'Income note',
      );

      final companion = domain.toDB();

      expect(companion.id.value, 'inc-1');
      expect(companion.type.value, TransactionType.income.name);
      expect(companion.amount.value, testAmount);
      expect(companion.date.value, testDate);
      expect(companion.notes.value, 'Income note');
      expect(companion.walletId.value, 'wallet-1');
      expect(companion.incomeCategoryId.value, 'income-cat-1');
    });

    test('returns correct TransactionDBCompanion for ExpenseTransaction', () {
      final domain = Transaction.expense(
        id: 'exp-1',
        walletId: 'wallet-1',
        expenseCategoryId: 'expense-cat-1',
        amount: testAmount,
        date: testDate,
        notes: 'Expense note',
      );

      final companion = domain.toDB();

      expect(companion.id.value, 'exp-1');
      expect(companion.type.value, TransactionType.expense.name);
      expect(companion.amount.value, testAmount);
      expect(companion.date.value, testDate);
      expect(companion.notes.value, 'Expense note');
      expect(companion.walletId.value, 'wallet-1');
      expect(companion.expenseCategoryId.value, 'expense-cat-1');
    });

    test('returns correct TransactionDBCompanion for TransferTransaction', () {
      final domain = Transaction.transfer(
        id: 'trans-1',
        sourceWalletId: 'wallet-src',
        destinationWalletId: 'wallet-dst',
        amount: testAmount,
        fee: testFee,
        date: testDate,
        notes: 'Transfer note',
      );

      final companion = domain.toDB();

      expect(companion.id.value, 'trans-1');
      expect(companion.type.value, TransactionType.transfer.name);
      expect(companion.amount.value, testAmount);
      expect(companion.fee.value, testFee);
      expect(companion.date.value, testDate);
      expect(companion.notes.value, 'Transfer note');
      expect(companion.sourceWalletId.value, 'wallet-src');
      expect(companion.destinationWalletId.value, 'wallet-dst');
    });
  });
}
