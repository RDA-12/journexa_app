import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/data/repositories/transaction/firestore_transaction.dart';
import 'package:journexa_app/domain/entities/expense_category.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:journexa_app/domain/entities/wallet.dart';

void main() {
  group('FirestoreTransaction.fromDomain', () {
    final date = DateTime.now();
    test('returns correct transaction for income', () {
      final income = IncomeTransaction(
        id: 'id',
        wallet: Wallet.test(),
        category: IncomeCategory.test(),
        amount: Decimal.fromInt(100),
        date: date,
        notes: 'Test income',
      );
      final expected = FirestoreIncomeTransaction(
        id: income.id,
        $type: 'income',
        walletId: 'id',
        incomeCategoryId: 'id',
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
        wallet: Wallet.test(),
        category: ExpenseCategory.test(),
        amount: Decimal.fromInt(100),
        date: date,
        notes: 'Test expense',
      );
      final expected = FirestoreExpenseTransaction(
        id: expense.id,
        $type: 'expense',
        walletId: 'id',
        expenseCategoryId: 'id',
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
        source: Wallet.test(),
        destination: Wallet.test()
            .update(name: 'wallet 2')
            .copyWith(id: 'id-2'),
        amount: Decimal.fromInt(100),
        fee: Decimal.fromInt(10),
        date: date,
        notes: 'Test transfer',
      );
      final expected = FirestoreTransferTransaction(
        id: transfer.id,
        $type: 'transfer',
        sourceWalletId: 'id',
        destinationWalletId: 'id-2',
        amount: Decimal.fromInt(100),
        fee: Decimal.fromInt(10),
        date: date,
        notes: 'Test transfer',
      );

      final actual = FirestoreTransaction.fromDomain(transfer);

      expect(actual, expected);
    });
  });
}
