import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/expense_category.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/shared/app_exception.dart';

void main() {
  final wallet = Wallet.test();
  final incomeCategory = IncomeCategory.test();
  final expenseCategory = ExpenseCategory.test();

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
              category: incomeCategory,
              wallet: wallet,
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
              category: expenseCategory,
              wallet: wallet,
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
              source: wallet,
              destination: wallet.copyWith(id: 'id-2'),
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
        final source = Wallet.test();
        final destination = source;

        expect(
          () => Transaction.transfer(
            id: '0',
            source: source,
            destination: destination,
            amount: Decimal.fromInt(1000),
            fee: Decimal.fromInt(100),
            date: DateTime.now(),
          ),
          throwsA(
            isA<AppException>().having(
              (e) => e.message,
              'message',
              'source and destination wallet must be different. '
                  'Got: ${source.id} and ${destination.id}',
            ),
          ),
        );
      },
    );

    test(
      'throws AppException when fee < 0 '
      'in transfer transaction',
      () {
        final source = Wallet.test();
        final destination = source.copyWith(id: 'id-2');
        final fee = Decimal.fromInt(-100);

        expect(
          () => Transaction.transfer(
            id: '0',
            source: source,
            destination: destination,
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
