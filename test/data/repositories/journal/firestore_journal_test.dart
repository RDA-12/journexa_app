import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/data/repositories/journal/firestore_journal.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/journal.dart';

void main() {
  group(
    'FirestoreAccountBalance.fromDomain',
    () {
      test('should create FirestoreAccountBalance from AccountBalance', () {
        final account = Account.test();
        final balance = AccountBalance(
          account: account,
          balance: Decimal.zero,
        );
        final expected = FirestoreAccountBalance(
          code: account.code,
          balance: Decimal.zero,
        );

        expect(
          FirestoreAccountBalance.fromDomain(balance),
          expected,
        );
      });
    },
  );

  group(
    'FirestoreJournalEntry.fromDomain',
    () {
      test('should create FirestoreJournalEntry from JournalEntry', () {
        final entry = JournalEntry.test(
          transactionDate: DateTime.now(),
        );
        final expected = FirestoreJournalEntry(
          id: entry.id,
          transactionDate: entry.transactionDate,
          notes: entry.description,
        );

        expect(
          FirestoreJournalEntry.fromDomain(entry),
          expected,
        );
      });
    },
  );

  group(
    'FirestoreJournalEntryLine.fromDomain',
    () {
      test('should create FirestoreJournalEntryLine from JournalEntryLine', () {
        final line = JournalEntryLine.test();
        final expected = FirestoreJournalEntryLine(
          accountCode: line.account.code,
          debit: line.debit,
          credit: line.credit,
        );

        expect(
          FirestoreJournalEntryLine.fromDomain(line),
          expected,
        );
      });
    },
  );
}
