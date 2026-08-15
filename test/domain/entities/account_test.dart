import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/shared/app_exception.dart';

void main() {
  final expectedPrefixCode = {
    AccountType.asset: '1',
    AccountType.revenue: '4',
    AccountType.liability: '2',
    AccountType.expense: '5',
    AccountType.equity: '3',
  };
  group('prefixCode', () {
    for (final type in AccountType.values) {
      test('$type should have ${expectedPrefixCode[type]} prefix code', () {
        expect(type.prefixCode, expectedPrefixCode[type]);
      });
    }
  });

  group('constructor', () {
    for (final type in AccountType.values) {
      test(
        'throws AppException when $type created '
        'with code not prefixed with ${expectedPrefixCode[type]}',
        () {
          expect(
            () => Account(code: '00', name: 'test', type: type),
            throwsA(
              AppException(
                'account with type $type must '
                'have code prefixed with ${expectedPrefixCode[type]}. '
                'got 0 instead',
                code: AppExceptionCode.internalException,
              ),
            ),
          );
        },
      );
    }

    test('throws AppException when code have invalid length', () {
      final invalidCodes = ['1132', '123.123.123'];

      for (final invalid in invalidCodes) {
        expect(
          () => Account(
            code: invalid,
            name: 'test',
            type: AccountType.asset,
          ),
          throwsA(
            AppException(
              'invalid code length. '
              'it must have 2 parts, system and user code, splitted by ".". '
              'got ${invalid.split('.')} instead',
              code: AppExceptionCode.internalException,
            ),
          ),
        );
      }
    });

    test(
      'throws AppException when system code in code dont have length 2',
      () {
        final invalidCodes = ['1.2322', '111.1111', '1111.1111'];

        for (final invalid in invalidCodes) {
          expect(
            () => Account(
              code: invalid,
              name: 'asset',
              type: AccountType.asset,
            ),
            throwsA(
              AppException(
                'invalid system part in code, it must 2 character long. '
                'got ${invalid.split('.')[0]} instead',
                code: AppExceptionCode.internalException,
              ),
            ),
          );
        }
      },
    );

    test(
      'throws AppException when user code in code dont have length 2',
      () {
        final invalidCodes = ['11.23221', '11.11', '11.1'];

        for (final invalid in invalidCodes) {
          expect(
            () => Account(
              code: invalid,
              name: 'asset',
              type: AccountType.asset,
            ),
            throwsA(
              AppException(
                'invalid user part in code, it must 4 character long. '
                'got ${invalid.split('.')[1]} instead',
                code: AppExceptionCode.internalException,
              ),
            ),
          );
        }
      },
    );
  });

  group('Account.user', () {
    final parents = kSystemDefinedAccounts;

    for (final parent in parents) {
      test('creates correct Account based on ${parent.type}', () {
        const currentChildrenCount = 100;
        final expectedCode = '${parent.code.split('.')[0]}.0101';
        final expectedAccount = Account(
          code: expectedCode,
          name: 'name',
          type: parent.type,
          parent: parent,
        );

        final result = Account.user(
          name: 'name',
          parent: parent,
          currentChildrenCount: currentChildrenCount,
        );

        expect(result, expectedAccount);
      });
    }
  });

  group('AccountType normalBalance getter', () {
    test(
      'returns list of account types with debit normal balance',
      () {
        expect(
          AccountType.debitNormalBalance,
          [AccountType.asset, AccountType.expense],
        );
      },
    );

    test(
      'returns list of account types with credit normal balance',
      () {
        expect(
          AccountType.creditNormalBalance,
          [AccountType.liability, AccountType.equity, AccountType.revenue],
        );
      },
    );
  });

  group(
    'Account.normalBalance getter',
    () {
      for (final type in AccountType.creditNormalBalance) {
        test(
          '$type has credit normal balance',
          () {
            final account = Account(
              code: '${type.prefixCode}0.0000',
              name: 'test',
              type: type,
            );

            expect(account.normalBalance, BalanceType.credit);
          },
        );
      }

      for (final type in AccountType.debitNormalBalance) {
        test(
          '$type has debit normal balance',
          () {
            final account = Account(
              code: '${type.prefixCode}0.0000',
              name: 'test',
              type: type,
            );

            expect(account.normalBalance, BalanceType.debit);
          },
        );
      }
    },
  );
}
