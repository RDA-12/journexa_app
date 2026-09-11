import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/data/repositories/journal/journal.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/journal.dart';

void main() {
  final testDate = DateTime(2026, 9, 7, 12);
  final testAccount = Account.sub(
    name: 'Asset Account',
    parent: SystemDefinedAccount.walletParent,
    currentChildrenCount: 0,
  );

  group('JournalEntry.toDB', () {
    test('returns correct JournalEntryDBCompanion', () {
      final domain = JournalEntry(
        id: 'entry-1',
        transactionDate: testDate,
        lines: [
          JournalEntryLine.fromAccount(
            account: testAccount,
            amount: Decimal.fromInt(100),
          ),
          JournalEntryLine.fromAccount(
            account: Account.test(AccountType.revenue),
            amount: Decimal.fromInt(100),
          ),
        ],
        description: 'Test entry',
      );

      final companion = domain.toDB();

      expect(companion.id.value, 'entry-1');
      expect(companion.transactionDate.value, testDate);
      expect(companion.notes.value, 'Test entry');
    });
  });

  group('JournalEntryLine.toDB', () {
    test('returns correct JournalEntryLineDBCompanion', () {
      final line = JournalEntryLine.fromAccount(
        account: testAccount,
        amount: Decimal.fromInt(100),
      );

      final companion = line.toDB(id: 'line-1', journalId: 'entry-1');

      expect(companion.id.value, 'line-1');
      expect(companion.journalId.value, 'entry-1');
      expect(companion.accountCode.value, testAccount.code.value);
      expect(companion.debit.value, Decimal.fromInt(100));
      expect(companion.credit.value, Decimal.zero);
    });
  });
}
