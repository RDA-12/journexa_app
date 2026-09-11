import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/journal.dart';
import 'package:journexa_app/shared/app_exception.dart';

void main() {
  final walletAccount = Account.sub(
    name: 'asset 1',
    parent: SystemDefinedAccount.walletParent,
    currentChildrenCount: 0,
  );
  final incomeAccount = Account.sub(
    name: 'revenue 1',
    parent: SystemDefinedAccount.incomeParent,
    currentChildrenCount: 0,
  );

  group(
    'constructor',
    () {
      test(
        'throws AppException when lines is not balanced',
        () {
          final line1 = JournalEntryLine(
            account: walletAccount,
            debit: Decimal.fromInt(10000),
            credit: Decimal.fromInt(0),
          );
          final line2 = JournalEntryLine(
            account: incomeAccount,
            debit: Decimal.fromInt(0),
            credit: Decimal.fromInt(5000),
          );

          expect(
            () => JournalEntry(
              id: 'id',
              transactionDate: DateTime.now(),
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
    'JournalEntryLine.fromAccount',
    () {
      for (final type in AccountType.debitNormalBalance) {
        test(
          '$type should set debit when amount is posivite',
          () {
            final line = JournalEntryLine.fromAccount(
              account: walletAccount,
              amount: Decimal.fromInt(1000),
            );
            expect(
              line,
              JournalEntryLine(
                account: walletAccount,
                debit: Decimal.fromInt(1000),
                credit: Decimal.zero,
              ),
            );
          },
        );

        test(
          '$type should set credit when amount is negative',
          () {
            final line = JournalEntryLine.fromAccount(
              account: walletAccount,
              amount: Decimal.fromInt(-1000),
            );
            expect(
              line,
              JournalEntryLine(
                account: walletAccount,
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
            final line = JournalEntryLine.fromAccount(
              account: incomeAccount,
              amount: Decimal.fromInt(1000),
            );
            expect(
              line,
              JournalEntryLine(
                account: incomeAccount,
                debit: Decimal.zero,
                credit: Decimal.fromInt(1000),
              ),
            );
          },
        );

        test(
          '$type should set debit when amount is negative',
          () {
            final line = JournalEntryLine.fromAccount(
              account: incomeAccount,
              amount: Decimal.fromInt(-1000),
            );
            expect(
              line,
              JournalEntryLine(
                account: incomeAccount,
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
