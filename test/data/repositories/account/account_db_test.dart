import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/data/database.dart';
import 'package:journexa_app/data/repositories/account/account.dart';
import 'package:journexa_app/domain/entities/account.dart';

void main() {
  group('AccountDBData.toDomain', () {
    test('returns correct Account', () {
      final expected = Account(
        code: AccountCode.fromString('1.001.001'),
        name: 'name',
        type: AccountType.asset,
      );
      const dbData = AccountDBData(
        code: '1.001.001',
        name: 'name',
        type: 'asset',
        isSystemAccount: false,
        isDeleted: false,
      );

      final actual = dbData.toDomain();

      expect(actual, expected);
    });

    test('returns correct Account with parent', () {
      final parent = SystemDefinedAccount.walletParent;
      final expected = Account(
        code: AccountCode.fromString('1.001.001'),
        name: 'name',
        type: AccountType.asset,
        parent: parent,
      );
      final dbData = AccountDBData(
        code: '1.001.001',
        name: 'name',
        type: 'asset',
        isSystemAccount: false,
        isDeleted: false,
        parentCode: parent.code.value,
      );

      final actual = dbData.toDomain(parent: parent);

      expect(actual, expected);
    });
  });

  group('Account.toDB', () {
    test('returns correct AccountDBCompanion', () {
      final expected = AccountDBCompanion.insert(
        code: '1.001',
        name: 'name',
        type: 'asset',
        isSystemAccount: const Value(true),
        parentCode: const Value(null),
      );
      final input = Account.root(
        systemCode: '001',
        name: 'name',
        type: AccountType.asset,
      );

      final actual = input.toDB();

      expect(actual, expected);
    });

    test('returns correct AccountDBCompanion with parent code', () {
      final parent = SystemDefinedAccount.walletParent;
      final expected = AccountDBCompanion.insert(
        code: '1.001.001',
        name: 'name',
        type: 'asset',
        isSystemAccount: const Value(false),
        parentCode: Value(parent.code.value),
      );
      final input = Account.sub(
        parent: parent,
        name: 'name',
        currentChildrenCount: 0,
      );

      final actual = input.toDB();

      expect(actual, expected);
    });
  });
}
