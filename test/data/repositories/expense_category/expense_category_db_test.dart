import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/data/database.dart';
import 'package:journexa_app/data/repositories/expense_category/expense_category.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/expense_category.dart';

void main() {
  group('ExpenseCategoryDBData.toDomain', () {
    test('returns correct ExpenseCategory', () {
      final expectedAccount = Account.sub(
        name: 'name',
        parent: SystemDefinedAccount.expenseParent,
        currentChildrenCount: 0,
      );
      final expected = ExpenseCategory(
        id: 'id',
        name: 'name',
        icon: 'icon',
        account: expectedAccount,
      );
      const dbData = ExpenseCategoryDBData(
        name: 'name',
        isDeleted: false,
        id: 'id',
        icon: 'icon',
        accountCode: '5.001.001',
      );

      final actual = dbData.toDomain(account: expectedAccount);

      expect(actual, expected);
    });
  });

  group('ExpenseCategory.toDB', () {
    test('returns correct ExpenseCategoryDBCompanion', () {
      final expected = ExpenseCategoryDBCompanion.insert(
        id: 'id',
        name: 'name',
        icon: 'icon',
        accountCode: '5.001.001',
      );
      final parentAccount = SystemDefinedAccount.expenseParent;
      final inputAccount = Account.sub(
        name: 'name',
        parent: parentAccount,
        currentChildrenCount: 0,
      );
      final input = ExpenseCategory(
        id: 'id',
        name: 'name',
        icon: 'icon',
        account: inputAccount,
      );

      final actual = input.toDB();

      expect(actual, expected);
    });
  });
}
