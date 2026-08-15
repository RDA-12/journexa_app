import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/journal.dart';
import 'package:journexa_app/shared/app_exception.dart';

void main() {
  final assetAccount = Account(
    code: '10.0001',
    name: 'asset 1',
    type: AccountType.asset,
  );
  final revenueAccount = Account(
    code: '40.0001',
    name: 'revenue 1',
    type: AccountType.revenue,
  );

  group(
    'constructor',
    () {
      test(
        'throws AppException when lines is not balanced',
        () {
          final line1 = JournalEntryLine(
            account: assetAccount,
            debit: Decimal.fromInt(10000),
            credit: Decimal.fromInt(0),
          );
          final line2 = JournalEntryLine(
            account: revenueAccount,
            debit: Decimal.fromInt(0),
            credit: Decimal.fromInt(5000),
          );

          expect(
            () => JournalEntry(
              id: 'id',
              createdAt: DateTime.now(),
              lines: [line1, line2],
            ),
            throwsA(
              isA<AppException>().having(
                (e) => e.message,
                'message',
                'lines must be balanced. current debit: 10000, credit: 5000',
              ),
            ),
          );
        },
      );
    },
  );

  group(
    'Account.createLine',
    () {
      for (final type in AccountType.debitNormalBalance) {
        test(
          '$type should set debit when amount is posivite',
          () {
            final line = assetAccount.createLine(Decimal.fromInt(1000));
            expect(
              line,
              JournalEntryLine(
                account: assetAccount,
                debit: Decimal.fromInt(1000),
                credit: Decimal.zero,
              ),
            );
          },
        );

        test(
          '$type should set credit when amount is negative',
          () {
            final line = assetAccount.createLine(-Decimal.fromInt(1000));
            expect(
              line,
              JournalEntryLine(
                account: assetAccount,
                debit: Decimal.zero,
                credit: Decimal.fromInt(1000),
              ),
            );
          },
        );
      }

      for (final type in AccountType.creditNormalBalance) {
        test(
          '$type should set credit when amount is posivite',
          () {
            final line = revenueAccount.createLine(Decimal.fromInt(1000));
            expect(
              line,
              JournalEntryLine(
                account: revenueAccount,
                debit: Decimal.zero,
                credit: Decimal.fromInt(1000),
              ),
            );
          },
        );

        test(
          '$type should set debit when amount is negative',
          () {
            final line = revenueAccount.createLine(-Decimal.fromInt(1000));
            expect(
              line,
              JournalEntryLine(
                account: revenueAccount,
                debit: Decimal.fromInt(1000),
                credit: Decimal.zero,
              ),
            );
          },
        );
      }
    },
  );
}
