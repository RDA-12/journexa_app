import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/expense_category.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/domain/entities/journal.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
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
              account: assetAccount,
              amount: Decimal.fromInt(1000),
            );
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
            final line = JournalEntryLine.fromAccount(
              account: assetAccount,
              amount: Decimal.fromInt(-1000),
            );
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
            final line = JournalEntryLine.fromAccount(
              account: revenueAccount,
              amount: Decimal.fromInt(1000),
            );
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
            final line = JournalEntryLine.fromAccount(
              account: revenueAccount,
              amount: Decimal.fromInt(-1000),
            );
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

  group('JournalEntry.fromTransaction', () {
    test('creates correct JournalEntry from income transaction', () {
      final amount = Decimal.fromInt(10000);
      final date = DateTime.now();
      final transaction = IncomeTransaction(
        id: '0',
        wallet: Wallet.test(),
        category: IncomeCategory.test(),
        amount: amount,
        date: date,
      );

      final expected = JournalEntry(
        id: 'id',
        transactionDate: date,
        lines: [
          JournalEntryLine(
            account: transaction.wallet.account,
            debit: amount,
            credit: Decimal.zero,
          ),
          JournalEntryLine(
            account: transaction.category.account,
            debit: Decimal.zero,
            credit: amount,
          ),
        ],
      );

      final actual = JournalEntry.fromTransaction(
        id: expected.id,
        transaction: transaction,
      );

      expect(actual, expected);
    });

    test('creates correct JournalEntry from expense transaction', () {
      final amount = Decimal.fromInt(10000);
      final date = DateTime.now();
      final transaction = ExpenseTransaction(
        id: '0',
        wallet: Wallet.test(),
        category: ExpenseCategory.test(),
        amount: amount,
        date: date,
      );

      final expected = JournalEntry(
        id: 'id',
        transactionDate: date,
        lines: [
          JournalEntryLine(
            account: transaction.wallet.account,
            debit: Decimal.zero,
            credit: amount,
          ),
          JournalEntryLine(
            account: transaction.category.account,
            debit: amount,
            credit: Decimal.zero,
          ),
        ],
      );

      final actual = JournalEntry.fromTransaction(
        id: expected.id,
        transaction: transaction,
      );

      expect(actual, expected);
    });

    test('creates correct JournalEntry from transfer transaction', () {
      final amount = Decimal.fromInt(10000);
      final fee = Decimal.fromInt(3500);
      final date = DateTime.now();
      final transaction = TransferTransaction(
        id: '0',
        source: Wallet.test(),
        destination: Wallet.test().update(name: 'wallet 2').copyWith(id: 'w-2'),
        amount: amount,
        fee: fee,
        date: date,
      );

      final expected = JournalEntry(
        id: 'id',
        transactionDate: date,
        lines: [
          JournalEntryLine(
            account: transaction.source.account,
            debit: Decimal.zero,
            credit: amount + fee,
          ),
          JournalEntryLine(
            account: transaction.destination.account,
            debit: amount,
            credit: Decimal.zero,
          ),
          JournalEntryLine(
            account: SystemDefinedAccount.feeTransfer,
            debit: fee,
            credit: Decimal.zero,
          ),
        ],
      );

      final actual = JournalEntry.fromTransaction(
        id: expected.id,
        transaction: transaction,
      );

      expect(actual, expected);
    });
  });
}
