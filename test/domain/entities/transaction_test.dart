import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:journexa_app/shared/app_exception.dart';

void main() {
  group('constructor', () {
    test(
      'throws AppException when amount is <= 0',
      () {
        for (final amount in [Decimal.zero, Decimal.fromInt(-1000)]) {
          expect(
            () => Transaction.income(
              id: '0',
              amount: amount,
              date: DateTime.now(),
              incomeCategoryId: 'income-1',
              walletId: 'wallet-1',
            ),
            throwsA(
              isA<AppException>().having(
                (e) => e.message,
                'message',
                'amount must be positive. Got: $amount',
              ),
            ),
          );
          expect(
            () => Transaction.expense(
              id: '0',
              amount: amount,
              date: DateTime.now(),
              expenseCategoryId: 'expense-1',
              walletId: 'wallet-1',
            ),
            throwsA(
              isA<AppException>().having(
                (e) => e.message,
                'message',
                'amount must be positive. Got: $amount',
              ),
            ),
          );
          expect(
            () => Transaction.transfer(
              id: '0',
              sourceWalletId: 'wallet-1',
              destinationWalletId: 'wallet-2',
              amount: amount,
              fee: Decimal.fromInt(100),
              date: DateTime.now(),
            ),
            throwsA(
              isA<AppException>().having(
                (e) => e.message,
                'message',
                'amount must be positive. Got: $amount',
              ),
            ),
          );
        }
      },
    );

    test(
      'throws AppException when source and destination wallet are same '
      'in transfer transaction',
      () {
        const sourceWalletId = 'wallet-1';
        const destinationWalletId = 'wallet-1';

        expect(
          () => Transaction.transfer(
            id: '0',
            sourceWalletId: sourceWalletId,
            destinationWalletId: destinationWalletId,
            amount: Decimal.fromInt(1000),
            fee: Decimal.fromInt(100),
            date: DateTime.now(),
          ),
          throwsA(
            isA<AppException>().having(
              (e) => e.message,
              'message',
              'source and destination wallet must be different. '
                  'Got: $sourceWalletId and $destinationWalletId',
            ),
          ),
        );
      },
    );

    test(
      'throws AppException when fee < 0 '
      'in transfer transaction',
      () {
        final fee = Decimal.fromInt(-100);

        expect(
          () => Transaction.transfer(
            id: '0',
            sourceWalletId: 'wallet-1',
            destinationWalletId: 'wallet-2',
            amount: Decimal.fromInt(1000),
            fee: fee,
            date: DateTime.now(),
          ),
          throwsA(
            isA<AppException>().having(
              (e) => e.message,
              'message',
              'fee must be 0 or positive. Got: $fee',
            ),
          ),
        );
      },
    );
  });
}
