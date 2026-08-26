import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/data/repositories/expense_category/firestore_expense_category.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/expense_category.dart';

void main() {
  group('fromDomain', () {
    test('returns correct FirestoreExpenseCategory', () {
      const expected = FirestoreExpenseCategory(
        id: 'id',
        name: 'Name',
        nameLower: 'name',
        icon: 'icon',
        accountCode: '50.1001',
      );
      final domain = ExpenseCategory(
        id: expected.id,
        name: expected.name,
        icon: expected.icon,
        account: Account(
          code: expected.accountCode,
          name: 'expense',
          type: AccountType.expense,
          parent: SystemDefinedAccount.rootExpense,
        ),
      );

      expect(FirestoreExpenseCategory.fromDomain(domain), expected);
    });
  });

  group('toDomain', () {
    test('returns correct ExpenseCategory', () {
      const firestoreExpenseCategory = FirestoreExpenseCategory(
        id: 'id',
        name: 'Name',
        nameLower: 'name',
        icon: 'icon',
        accountCode: '50.1001',
      );
      final account = Account(
        code: '50.1001',
        name: 'expense',
        type: AccountType.expense,
        parent: SystemDefinedAccount.rootExpense,
      );
      final expected = ExpenseCategory(
        id: 'id',
        name: 'Name',
        icon: 'icon',
        account: account,
      );

      expect(firestoreExpenseCategory.toDomain(account), expected);
    });
  });
}
