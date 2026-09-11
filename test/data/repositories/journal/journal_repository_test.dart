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

  final assetParent = SystemDefinedAccount.rootAsset;
  final revenueParent = SystemDefinedAccount.rootRevenue;

  final debitAccount = Account(
    code: '10.0001',
    name: 'asset 1',
    type: AccountType.asset,
    parent: assetParent,
  );
  final creditAccount = Account(
    code: '40.0001',
    name: 'revenue 1',
    type: AccountType.revenue,
    parent: revenueParent,
  );
  final debitBalance = Decimal.fromInt(10000);

  late AppLocalDatabase db;
  late IJournalRepository repository;

  setUp(() async {
    db = AppLocalDatabase.test();
    await db.into(db.accountDB).insert(assetParent.toDB());
    await db.into(db.accountDB).insert(revenueParent.toDB());
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
      final zeroBalanceAccount = Account(
        code: '10.1000',
        name: 'zero-balance',
        type: AccountType.asset,
        parent: assetParent,
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
            debitAccount.code: debitBalance,
            creditAccount.code: Decimal.fromInt(10000),
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
              debitAccount.code: Decimal.fromInt(5000),
              creditAccount.code: Decimal.fromInt(5000),
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
              debitAccount.code: Decimal.fromInt(10000),
              creditAccount.code: Decimal.fromInt(10000),
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
              debitAccount.code: Decimal.fromInt(15000),
              creditAccount.code: Decimal.fromInt(15000),
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
      final zeroBalanceAccount = Account(
        code: '10.1000',
        name: 'zero-balance',
        type: AccountType.asset,
        parent: assetParent,
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
          await db.into(db.journalEntryLineDB).insert(
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
