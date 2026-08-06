import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/data/repositories/account/firestore_account.dart';
import 'package:journexa_app/domain/entities/account.dart';

void main() {
  group('fromDomain', () {
    test('returns correct FirestoreAccount', () {
      const expected = FirestoreAccount(
        code: '10.0000',
        name: 'asset',
        type: AccountType.asset,
        parentCode: '10.0001',
      );
      final parent = Account(
        code: expected.parentCode!,
        name: 'parent ${expected.name}',
        type: expected.type,
      );
      final domain = Account(
        code: expected.code,
        name: expected.name,
        type: expected.type,
        parent: parent,
      );

      final result = FirestoreAccount.fromDomain(domain);

      expect(result, expected);
    });
  });

  group('toDomain', () {
    test('returns correct Account', () {
      final expected = Account(
        code: '10.0000',
        name: 'asset',
        type: AccountType.asset,
      );
      final firestoreAccount = FirestoreAccount(
        code: expected.code,
        name: expected.name,
        type: expected.type,
      );

      final result = firestoreAccount.toDomain();

      expect(result, expected);
    });
  });
}
