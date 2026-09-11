import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/data/database.dart';
import 'package:journexa_app/data/repositories/wallet/wallet.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/wallet.dart';

void main() {
  group('WalletDBData.toDomain', () {
    test('returns correct Wallet', () {
      final expectedAccount = Account.sub(
        name: 'name',
        parent: SystemDefinedAccount.walletParent,
        currentChildrenCount: 0,
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
        accountCode: '1.001.001',
      );
      final parentAccount = SystemDefinedAccount.walletParent;
      final inputAccount = Account.sub(
        name: 'name',
        parent: parentAccount,
        currentChildrenCount: 0,
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
