import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/data/repositories/account/firestore_account.dart';
import 'package:journexa_app/data/repositories/wallet/firestore_wallet.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/wallet.dart';

void main() {
  group('fromDomain', () {
    test('returns correct FirestoreWallet', () {
      final expectedAccount = FirestoreAccount(
        code: '10.0001',
        name: 'Asset',
        nameLower: 'asset',
        type: AccountType.asset,
        parentCode: SystemDefinedAccount.rootAsset.code,
        isSystemAccount: true,
        // ignore: avoid_redundant_argument_values need explicit for testing
        isDeleted: false,
      );
      final expected = FirestoreWallet(
        id: 'id',
        name: 'Asset',
        nameLower: 'asset',
        accountCode: expectedAccount.code,
      );
      final domainAccount = Account(
        code: expectedAccount.code,
        name: expectedAccount.name,
        type: expectedAccount.type,
        parent: SystemDefinedAccount.rootAsset,
        isSystemAccount: expectedAccount.isSystemAccount,
      );
      final domainWallet = Wallet(
        id: expected.id,
        name: expected.name,
        account: domainAccount,
      );

      final result = FirestoreWallet.fromDomain(domainWallet);

      expect(result, expected);
    });
  });

  group('toDomain', () {
    test('returns correct Wallet', () {
      final expectedAccount = Account(
        code: '10.0001',
        name: 'asset',
        type: AccountType.asset,
        isSystemAccount: true,
        parent: SystemDefinedAccount.rootAsset,
      );
      final expected = Wallet(
        id: 'id',
        name: 'asset',
        account: expectedAccount,
      );
      final firestoreAccount = FirestoreAccount(
        code: expectedAccount.code,
        name: expectedAccount.name,
        nameLower: expectedAccount.name.toLowerCase(),
        type: expectedAccount.type,
        isSystemAccount: expectedAccount.isSystemAccount,
      );
      final firestoreWallet = FirestoreWallet(
        id: expected.id,
        name: expected.name,
        nameLower: expected.name.toLowerCase(),
        accountCode: firestoreAccount.code,
      );

      final result = firestoreWallet.toDomain(expectedAccount);

      expect(result, expected);
    });
  });
}
