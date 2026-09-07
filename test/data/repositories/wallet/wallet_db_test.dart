import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/data/database.dart';
import 'package:journexa_app/data/repositories/wallet/wallet.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/wallet.dart';

void main() {
  group('WalletDBData.toDomain', () {
    test('returns correct Wallet', () {
      final expectedAccount = Account(
        code: '10.0001',
        name: 'name',
        type: AccountType.asset,
        parent: SystemDefinedAccount.rootAsset,
      );
      final expected = Wallet(
        id: 'id',
        name: 'name',
        account: expectedAccount,
      );
      const dbData = WalletDBData(
        name: 'name',
        isDeleted: false,
        id: 'id',
        accountCode: '10.0001',
      );

      final actual = dbData.toDomain(account: expectedAccount);

      expect(actual, expected);
    });
  });

  group('Wallet.toDB', () {
    test('returns correct WalletDBCompanion', () {
      final expected = WalletDBCompanion.insert(
        id: 'id',
        name: 'name',
        accountCode: '10.0001',
      );
      final parentAccount = SystemDefinedAccount.rootAsset;
      final inputAccount = Account(
        code: '10.0001',
        name: 'name',
        type: AccountType.asset,
        parent: parentAccount,
      );
      final input = Wallet(
        id: 'id',
        name: 'name',
        account: inputAccount,
      );

      final actual = input.toDB();

      expect(actual, expected);
    });
  });
}
