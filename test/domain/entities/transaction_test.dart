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
        }
      },
    );
  });
}
