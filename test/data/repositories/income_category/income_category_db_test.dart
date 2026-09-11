import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/data/database.dart';
import 'package:journexa_app/data/repositories/income_category/income_category.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/income_category.dart';

void main() {
  group('IncomeCategoryDBData.toDomain', () {
    test('returns correct IncomeCategory', () {
      final expectedAccount = Account.sub(
        name: 'name',
        parent: SystemDefinedAccount.incomeParent,
        currentChildrenCount: 0,
      );
      final expected = IncomeCategory(
        id: 'id',
        name: 'name',
        icon: 'icon',
        account: expectedAccount,
      );
      const dbData = IncomeCategoryDBData(
        name: 'name',
        isDeleted: false,
        id: 'id',
        icon: 'icon',
        accountCode: '4.001.001',
      );

      final actual = dbData.toDomain(account: expectedAccount);

      expect(actual, expected);
    });
  });

  group('IncomeCategory.toDB', () {
    test('returns correct IncomeCategoryDBCompanion', () {
      final expected = IncomeCategoryDBCompanion.insert(
        id: 'id',
        name: 'name',
        icon: 'icon',
        accountCode: '4.001.001',
      );
      final parentAccount = SystemDefinedAccount.incomeParent;
      final inputAccount = Account.sub(
        name: 'name',
        parent: parentAccount,
        currentChildrenCount: 0,
      );
      final input = IncomeCategory(
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
