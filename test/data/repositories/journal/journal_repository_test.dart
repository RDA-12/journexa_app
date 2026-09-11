import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/data/database.dart';
import 'package:journexa_app/data/repositories/account/account.dart';
import 'package:journexa_app/data/repositories/journal/journal.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/journal.dart';
import 'package:journexa_app/domain/repositories/i_journal_repository.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

void main() {
  const traceId = 'traceId';

  final walletParent = SystemDefinedAccount.walletParent;
  final incomeParent = SystemDefinedAccount.incomeParent;

  final debitAccount = Account.sub(
    name: 'asset 1',
    parent: walletParent,
    currentChildrenCount: 0,
  );
  final creditAccount = Account.sub(
    name: 'revenue 1',
    parent: incomeParent,
    currentChildrenCount: 0,
  );
  final debitBalance = Decimal.fromInt(10000);

  late AppLocalDatabase db;
  late IJournalRepository repository;

  setUp(() async {
    db = AppLocalDatabase.test();
    await db.into(db.accountDB).insert(walletParent.toDB());
    await db.into(db.accountDB).insert(incomeParent.toDB());
    await db.into(db.accountDB).insert(debitAccount.toDB());
    await db.into(db.accountDB).insert(creditAccount.toDB());

    final entry = JournalEntry(
      id: 'entry-1',
      transactionDate: DateTime(2026, 9, 7),
      lines: [
        JournalEntryLine.fromAccount(
          account: debitAccount,
          amount: Decimal.fromInt(10000),
        ),
        JournalEntryLine.fromAccount(
          account: creditAccount,
          amount: Decimal.fromInt(10000),
        ),
      ],
    );

    await db.into(db.journalEntryDB).insert(entry.toDB());
    for (var i = 0; i < entry.lines.length; i++) {
      await db
          .into(db.journalEntryLineDB)
          .insert(
            entry.lines[i].toDB(id: 'line-$i', journalId: entry.id),
          );
    }

    repository = DriftJournalRepository(db: db);
  });

  tearDown(() async {
    await db.delete(db.journalEntryLineDB).go();
    await db.delete(db.journalEntryDB).go();
    await db.delete(db.accountDB).go();
    await db.close();
  });

  group('getAccountBalance', () {
    test(
      'returns success with correct balance for debit normal balance account',
      () async {
        final result = await repository.getAccountBalance(
          account: debitAccount,
          traceId: traceId,
        );

        expect(
          result,
          AppResult.success(Decimal.fromInt(10000)),
        );
      },
    );

    test(
      'returns success with correct balance for credit normal balance account',
      () async {
        final result = await repository.getAccountBalance(
          account: creditAccount,
          traceId: traceId,
        );

        expect(
          result,
          AppResult.success(Decimal.fromInt(10000)),
        );
      },
    );

    test('returns success with zero balance for non-exists accounts', () async {
      final zeroBalanceAccount = Account.sub(
        name: 'zero-balance',
        parent: walletParent,
        currentChildrenCount: 10,
      );

      final result = await repository.getAccountBalance(
        account: zeroBalanceAccount,
        traceId: traceId,
      );

      expect(
        result,
        AppResult.success(Decimal.zero),
      );
    });

    test(
      'returns success with aggregated balance for parent account '
      'across multiple child and nested sub-accounts',
      () async {
        final wallet1 = debitAccount; // 1.001.001 (has 10000 in setUp)

        final wallet2 = Account.sub(
          name: 'wallet 2',
          parent: walletParent,
          currentChildrenCount: 1,
        ); // 1.001.002

        final subPocket = Account.sub(
          name: 'sub pocket',
          parent: wallet1,
          currentChildrenCount: 0,
        ); // 1.001.001.001

        final otherParent = Account.root(
          name: 'other parent',
          type: AccountType.asset,
          systemCode: '002',
        ); // 1.002

        final otherWallet = Account.sub(
          name: 'other wallet',
          parent: otherParent,
          currentChildrenCount: 0,
        ); // 1.002.001

        await db.into(db.accountDB).insert(wallet2.toDB());
        await db.into(db.accountDB).insert(subPocket.toDB());
        await db.into(db.accountDB).insert(otherParent.toDB());
        await db.into(db.accountDB).insert(otherWallet.toDB());

        final extraEntry = JournalEntry(
          id: 'entry-extra',
          transactionDate: DateTime(2026, 9, 8),
          lines: [
            JournalEntryLine.fromAccount(
              account: wallet2,
              amount: Decimal.fromInt(5000),
            ),
            JournalEntryLine.fromAccount(
              account: subPocket,
              amount: Decimal.fromInt(2500),
            ),
            JournalEntryLine.fromAccount(
              account: otherWallet,
              amount: Decimal.fromInt(99000),
            ),
            JournalEntryLine.fromAccount(
              account: creditAccount,
              amount: Decimal.fromInt(106500),
            ),
          ],
        );
        await db.into(db.journalEntryDB).insert(extraEntry.toDB());
        for (var i = 0; i < extraEntry.lines.length; i++) {
          await db
              .into(db.journalEntryLineDB)
              .insert(
                extraEntry.lines[i].toDB(
                  id: 'line-extra-$i',
                  journalId: extraEntry.id,
                ),
              );
        }

        // Parent rollup:
        // wallet1 (10000) + wallet2 (5000) + subPocket (2500) = 17500
        final parentResult = await repository.getAccountBalance(
          account: walletParent,
          traceId: traceId,
        );
        expect(
          parentResult,
          AppResult.success(Decimal.fromInt(17500)),
        );

        // Sub-parent rollup: wallet1 (10000) + subPocket (2500) = 12500
        final wallet1Result = await repository.getAccountBalance(
          account: wallet1,
          traceId: traceId,
        );
        expect(
          wallet1Result,
          AppResult.success(Decimal.fromInt(12500)),
        );

        // Leaf account: wallet2 (5000)
        final wallet2Result = await repository.getAccountBalance(
          account: wallet2,
          traceId: traceId,
        );
        expect(
          wallet2Result,
          AppResult.success(Decimal.fromInt(5000)),
        );
      },
    );

    test(
      'returns failure with internalException code '
      'when db throws Exception',
      () async {
        whenCalling(
          Invocation.method(#getAccountBalance, null),
        ).on(repository).thenThrow(Exception());

        final result = await repository.getAccountBalance(
          account: debitAccount,
          traceId: traceId,
        );

        expect(
          result,
          isA<AppResultFailure<Decimal>>().having(
            (e) => e.error.code,
            'error.code',
            AppExceptionCode.internalException,
          ),
        );
      },
    );
  });

  group('watchAccountBalances', () {
    test('emits success with correct mapped data', () async {
      final result = repository.watchAccountBalances(
        traceId: traceId,
      );

      expect(
        result,
        emits(
          AppResult.success({
            debitAccount.code.value: debitBalance,
            creditAccount.code.value: Decimal.fromInt(10000),
          }),
        ),
      );
    });

    test(
      'emits filtered data when from and to filters are provided',
      () async {
        final entry2 = JournalEntry(
          id: 'entry-2',
          transactionDate: DateTime(2026, 9, 15),
          lines: [
            JournalEntryLine.fromAccount(
              account: debitAccount,
              amount: Decimal.fromInt(5000),
            ),
            JournalEntryLine.fromAccount(
              account: creditAccount,
              amount: Decimal.fromInt(5000),
            ),
          ],
        );
        await db.into(db.journalEntryDB).insert(entry2.toDB());
        for (var i = 0; i < entry2.lines.length; i++) {
          await db
              .into(db.journalEntryLineDB)
              .insert(
                entry2.lines[i].toDB(
                  id: 'line-entry2-$i',
                  journalId: entry2.id,
                ),
              );
        }

        // Filter: only entries from 2026-09-10 (includes entry-2 only)
        final fromResult = repository.watchAccountBalances(
          traceId: traceId,
          from: DateTime(2026, 9, 10),
        );
        expect(
          fromResult,
          emits(
            AppResult.success({
              debitAccount.code.value: Decimal.fromInt(5000),
              creditAccount.code.value: Decimal.fromInt(5000),
            }),
          ),
        );

        // Filter: only entries up to 2026-09-10 (includes entry-1 only)
        final toResult = repository.watchAccountBalances(
          traceId: traceId,
          to: DateTime(2026, 9, 10),
        );
        expect(
          toResult,
          emits(
            AppResult.success({
              debitAccount.code.value: Decimal.fromInt(10000),
              creditAccount.code.value: Decimal.fromInt(10000),
            }),
          ),
        );

        // Filter: date range matching both entries (2026-09-07 to 2026-09-15)
        final rangeResult = repository.watchAccountBalances(
          traceId: traceId,
          from: DateTime(2026, 9, 7),
          to: DateTime(2026, 9, 15),
        );
        expect(
          rangeResult,
          emits(
            AppResult.success({
              debitAccount.code.value: Decimal.fromInt(15000),
              creditAccount.code.value: Decimal.fromInt(15000),
            }),
          ),
        );

        // Filter: date range matching no entries
        final emptyResult = repository.watchAccountBalances(
          traceId: traceId,
          from: DateTime(2026, 9, 8),
          to: DateTime(2026, 9, 14),
        );
        expect(
          emptyResult,
          emits(
            const AppResult.success(<String, Decimal>{}),
          ),
        );
      },
    );

    test(
      'emits failure with internalException code '
      'when db emits DriftWrappedException',
      () async {
        whenCalling(
          Invocation.method(#watchAccountBalances, null),
        ).on(repository).thenThrow(DriftWrappedException(message: ''));

        final result = repository.watchAccountBalances(
          traceId: traceId,
        );

        expect(
          result,
          emits(
            isA<AppResultFailure<Map<String, Decimal>>>().having(
              (e) => e.error.code,
              'error.code',
              AppExceptionCode.internalException,
            ),
          ),
        );
      },
    );

    test(
      'emits failure with internalException code '
      'when db throws Exception',
      () async {
        whenCalling(
          Invocation.method(#watchAccountBalances, null),
        ).on(repository).thenThrow(Exception());

        final result = repository.watchAccountBalances(
          traceId: traceId,
        );

        expect(
          result,
          emits(
            isA<AppResultFailure<Map<String, Decimal>>>().having(
              (e) => e.error.code,
              'error.code',
              AppExceptionCode.internalException,
            ),
          ),
        );
      },
    );
  });

  group('watchAccountBalance', () {
    test(
      'emits success with correct balance for debit normal balance account',
      () async {
        final result = repository.watchAccountBalance(
          account: debitAccount,
          traceId: traceId,
        );

        expect(
          result,
          emits(
            AppResult.success(Decimal.fromInt(10000)),
          ),
        );
      },
    );

    test(
      'emits success with correct balance for credit normal balance account',
      () async {
        final result = repository.watchAccountBalance(
          account: creditAccount,
          traceId: traceId,
        );

        expect(
          result,
          emits(
            AppResult.success(Decimal.fromInt(10000)),
          ),
        );
      },
    );

    test('emits success with zero balance for non-exists accounts', () async {
      final zeroBalanceAccount = Account.sub(
        name: 'zero-balance',
        parent: walletParent,
        currentChildrenCount: 10,
      );

      final result = repository.watchAccountBalance(
        account: zeroBalanceAccount,
        traceId: traceId,
      );

      expect(
        result,
        emits(
          AppResult.success(Decimal.zero),
        ),
      );
    });

    test(
      'emits filtered data when from and to filters are provided',
      () async {
        final entry2 = JournalEntry(
          id: 'entry-2',
          transactionDate: DateTime(2026, 9, 15),
          lines: [
            JournalEntryLine.fromAccount(
              account: debitAccount,
              amount: Decimal.fromInt(5000),
            ),
            JournalEntryLine.fromAccount(
              account: creditAccount,
              amount: Decimal.fromInt(5000),
            ),
          ],
        );
        await db.into(db.journalEntryDB).insert(entry2.toDB());
        for (var i = 0; i < entry2.lines.length; i++) {
          await db
              .into(db.journalEntryLineDB)
              .insert(
                entry2.lines[i].toDB(
                  id: 'line-entry2-$i',
                  journalId: entry2.id,
                ),
              );
        }

        // Filter: only entries from 2026-09-10 (includes entry-2 only)
        final fromResult = repository.watchAccountBalance(
          account: debitAccount,
          traceId: traceId,
          from: DateTime(2026, 9, 10),
        );
        expect(
          fromResult,
          emits(
            AppResult.success(Decimal.fromInt(5000)),
          ),
        );

        // Filter: only entries up to 2026-09-10 (includes entry-1 only)
        final toResult = repository.watchAccountBalance(
          account: debitAccount,
          traceId: traceId,
          to: DateTime(2026, 9, 10),
        );
        expect(
          toResult,
          emits(
            AppResult.success(Decimal.fromInt(10000)),
          ),
        );

        // Filter: date range matching both entries (2026-09-07 to 2026-09-15)
        final rangeResult = repository.watchAccountBalance(
          account: debitAccount,
          traceId: traceId,
          from: DateTime(2026, 9, 7),
          to: DateTime(2026, 9, 15),
        );
        expect(
          rangeResult,
          emits(
            AppResult.success(Decimal.fromInt(15000)),
          ),
        );

        // Filter: date range matching no entries
        final emptyResult = repository.watchAccountBalance(
          account: debitAccount,
          traceId: traceId,
          from: DateTime(2026, 9, 8),
          to: DateTime(2026, 9, 14),
        );
        expect(
          emptyResult,
          emits(
            AppResult.success(Decimal.zero),
          ),
        );
      },
    );

    test(
      'emits updated aggregated balance for parent account '
      'when sub-account entries change',
      () async {
        final wallet2 = Account.sub(
          name: 'wallet 2',
          parent: walletParent,
          currentChildrenCount: 1,
        ); // 1.001.002

        await db.into(db.accountDB).insert(wallet2.toDB());

        final stream = repository.watchAccountBalance(
          account: walletParent,
          traceId: traceId,
        );

        expect(
          stream,
          emitsInOrder([
            // Initial balance from debitAccount (10000)
            AppResult.success(Decimal.fromInt(10000)),
            // Balance after adding entry to wallet2 (10000 + 5000 = 15000)
            AppResult.success(Decimal.fromInt(15000)),
          ]),
        );

        // Wait a tick for the first emission, then insert the new entry
        await Future<void>.delayed(Duration.zero);

        final entry2 = JournalEntry(
          id: 'entry-sub-wallet',
          transactionDate: DateTime(2026, 9, 8),
          lines: [
            JournalEntryLine.fromAccount(
              account: wallet2,
              amount: Decimal.fromInt(5000),
            ),
            JournalEntryLine.fromAccount(
              account: creditAccount,
              amount: Decimal.fromInt(5000),
            ),
          ],
        );
        await db.transaction(() async {
          await db.into(db.journalEntryDB).insert(entry2.toDB());
          for (var i = 0; i < entry2.lines.length; i++) {
            await db
                .into(db.journalEntryLineDB)
                .insert(
                  entry2.lines[i].toDB(
                    id: 'line-sub-wallet-$i',
                    journalId: entry2.id,
                  ),
                );
          }
        });
      },
    );

    test(
      'emits failure with internalException code '
      'when db throws Exception',
      () async {
        whenCalling(
          Invocation.method(#watchAccountBalance, null),
        ).on(repository).thenThrow(Exception());

        final result = repository.watchAccountBalance(
          account: debitAccount,
          traceId: traceId,
        );

        expect(
          result,
          emits(
            isA<AppResultFailure<Decimal>>().having(
              (e) => e.error.code,
              'error.code',
              AppExceptionCode.internalException,
            ),
          ),
        );
      },
    );
  });
}
