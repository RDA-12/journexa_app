import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/data/repositories/income_category/firestore_income_category.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/income_category.dart';

void main() {
  group('fromDomain', () {
    test('returns correct FirestoreIncomeCategory', () {
      const expected = FirestoreIncomeCategory(
        id: 'id',
        name: 'name',
        icon: 'icon',
        accountCode: '40.1001',
      );
      final domain = IncomeCategory(
        id: expected.id,
        name: expected.name,
        icon: expected.icon,
        account: Account(
          code: expected.accountCode,
          name: 'revenue',
          type: AccountType.revenue,
          parent: SystemDefinedAccount.rootRevenue,
        ),
      );

      expect(FirestoreIncomeCategory.fromDomain(domain), expected);
    });
  });

  group('toDomain', () {
    test('returns correct IncomeCategory', () {
      const firestoreIncomeCategory = FirestoreIncomeCategory(
        id: 'id',
        name: 'name',
        icon: 'icon',
        accountCode: '40.1001',
      );
      final account = Account(
        code: '40.1001',
        name: 'revenue',
        type: AccountType.revenue,
        parent: SystemDefinedAccount.rootRevenue,
      );
      final expected = IncomeCategory(
        id: 'id',
        name: 'name',
        icon: 'icon',
        account: account,
      );

      expect(firestoreIncomeCategory.toDomain(account), expected);
    });
  });
}
