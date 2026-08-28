import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/shared/app_exception.dart';

void main() {
  final wallet = Wallet.test();
  final incomeCategory = IncomeCategory.test();

  group('constructor', () {
    test(
      'throws AppException when amount is <= 0',
      () {
        expect(
          () => Transaction.income(
            id: '0',
            amount: Decimal.zero,
            date: DateTime.now(),
            category: incomeCategory,
            wallet: wallet,
          ),
          throwsA(
            isA<AppException>().having(
              (e) => e.message,
              'message',
              'amount must be positive. Got: 0',
            ),
          ),
        );
        expect(
          () => Transaction.income(
            id: '0',
            amount: -Decimal.fromInt(10),
            date: DateTime.now(),
            category: incomeCategory,
            wallet: wallet,
          ),
          throwsA(
            isA<AppException>().having(
              (e) => e.message,
              'message',
              'amount must be positive. Got: -10',
            ),
          ),
        );
      },
    );
  });
}
