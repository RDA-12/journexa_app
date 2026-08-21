import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/shared/app_exception.dart';

void main() {
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
  });
}
