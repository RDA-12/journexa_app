import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/shared/app_exception.dart';

void main() {
  final assetParent = SystemDefinedAccount.rootAsset;
  group('constructor', () {
    test(
      'throws AppException when connected Account is not an asset',
      () async {
        expect(
          () => Wallet(
            id: '1234',
            name: 'name',
            account: Account(
              code: '40.0001',
              name: 'name',
              type: AccountType.revenue,
              parent: assetParent,
            ),
          ),
          throwsA(
            isA<AppException>().having(
              (e) => e.message,
              'message',
              'Wallet must have asset typed Account. '
                  'Got: AccountType.revenue',
            ),
          ),
        );
      },
    );

    test(
      'throws AppException when connected Account name dont match Wallet name',
      () async {
        expect(
          () => Wallet(
            id: '1234',
            name: 'name',
            account: Account(
              code: '10.0001',
              name: 'asset',
              type: AccountType.asset,
              parent: assetParent,
            ),
          ),
          throwsA(
            isA<AppException>().having(
              (e) => e.message,
              'message',
              'Account name must match Wallet name. '
                  'Wallet name: name, Account name: asset',
            ),
          ),
        );
      },
    );

    test(
      'throws AppException when connected Account '
      'is not have asset Account as parent',
      () {
        final account = Account(
          code: '10.1200',
          name: 'name',
          type: AccountType.asset,
        );
        expect(
          () => Wallet(
            id: 'id',
            name: 'name',
            account: account,
          ),
          throwsA(
            isA<AppException>().having(
              (e) => e.message,
              'message',
              'Wallet account must have asset parent. '
                  'Got: ${account.parent?.code}',
            ),
          ),
        );
      },
    );
  });

  group('Wallet.update', () {
    test('update Wallet and Account name '
        'when name is provided', () {
      final expected = Wallet(
        id: 'id',
        name: 'new name',
        account: Account(
          code: '10.1200',
          name: 'new name',
          type: AccountType.asset,
          parent: assetParent,
        ),
      );
      final old = Wallet(
        id: 'id',
        name: 'old name',
        account: Account(
          code: '10.1200',
          name: 'old name',
          type: AccountType.asset,
          parent: assetParent,
        ),
      );

      expect(old.update(name: 'new name'), expected);
    });
  });
}
