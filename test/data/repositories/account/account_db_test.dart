import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/data/database.dart';
import 'package:journexa_app/data/repositories/account/account.dart';
import 'package:journexa_app/domain/entities/account.dart';

void main() {
  group('AccountDBData.toDomain', () {
    test('returns correct Account', () {
      final expected = Account(
        code: '10.0001',
        name: 'name',
        type: AccountType.asset,
      );
      const dbData = AccountDBData(
        code: '10.0001',
        name: 'name',
        type: 'asset',
        isSystemAccount: false,
        isDeleted: false,
      );

      final actual = dbData.toDomain();

      expect(actual, expected);
    });

    test('returns correct Account with parent', () {
      final parent = SystemDefinedAccount.rootAsset;
      final expected = Account(
        code: '10.0001',
        name: 'name',
        type: AccountType.asset,
        parent: parent,
      );
      const dbData = AccountDBData(
        code: '10.0001',
        name: 'name',
        type: 'asset',
        isSystemAccount: false,
        isDeleted: false,
        parentCode: '10.0000',
      );

      final actual = dbData.toDomain(parent: parent);

      expect(actual, expected);
    });
  });

  group('Account.toDB', () {
    test('returns correct AccountDBCompanion', () {
      final expected = AccountDBCompanion.insert(
        code: '10.0000',
        name: 'name',
        type: 'asset',
        isSystemAccount: const Value(true),
      );
      final input = Account(
        code: '10.0000',
        name: 'name',
        type: AccountType.asset,
        isSystemAccount: true,
      );

      final actual = input.toDB();

      expect(actual, expected);
    });

    test('returns correct AccountDBCompanion with parent code', () {
      final parent = SystemDefinedAccount.rootAsset;
      final expected = AccountDBCompanion.insert(
        code: '10.0001',
        name: 'name',
        type: 'asset',
        isSystemAccount: const Value(false),
        parentCode: Value(parent.code),
      );
      final input = Account(
        code: '10.0001',
        name: 'name',
        type: AccountType.asset,
        parent: parent,
      );

      final actual = input.toDB();

      expect(actual, expected);
    });
  });
}
