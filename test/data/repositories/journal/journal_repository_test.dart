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

  final debitAccountBalance = AccountBalance(
    account: debitAccount,
    balance: Decimal.fromInt(10000),
  );

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
      await db.into(db.journalEntryLineDB).insert(
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

  group('getCurrentBalance', () {
    test('returns success with correct mapped data', () async {
      final result = await repository.getCurrentBalance(
        accounts: [debitAccount],
        traceId: traceId,
      );

      expect(
        result,
        AppResult.success({debitAccount.code: debitAccountBalance}),
      );
    });

    test('returns success with zero balance for non-exists accounts', () async {
      final zeroBalanceAccount = Account(
        code: '10.1000',
        name: 'zero-balance',
        type: AccountType.asset,
        parent: assetParent,
      );

      final result = await repository.getCurrentBalance(
        accounts: [debitAccount, zeroBalanceAccount],
        traceId: traceId,
      );

      expect(
        result,
        AppResult.success({
          debitAccount.code: debitAccountBalance,
          zeroBalanceAccount.code: AccountBalance(
            account: zeroBalanceAccount,
            balance: Decimal.zero,
          ),
        }),
      );
    });

    test(
      'returns failure with internalException code '
      'when db throws Exception',
      () async {
        whenCalling(
          Invocation.method(#getCurrentBalance, null),
        ).on(repository).thenThrow(Exception());

        final result = await repository.getCurrentBalance(
          accounts: [debitAccount],
          traceId: traceId,
        );

        expect(
          result,
          isA<AppResultFailure<Map<String, AccountBalance>>>().having(
            (e) => e.error.code,
            'error.code',
            AppExceptionCode.internalException,
          ),
        );
      },
    );
  });

  group('watchCurrentBalance', () {
    test('emits success with correct mapped data', () async {
      final result = repository.watchCurrentBalance(
        traceId: traceId,
      );

      expect(
        result,
        emits(
          AppResult.success({
            debitAccount.code: debitAccountBalance.balance,
            creditAccount.code: Decimal.fromInt(10000),
          }),
        ),
      );
    });

    test(
      'emits failure with internalException code '
      'when db emits DriftWrappedException',
      () async {
        whenCalling(
          Invocation.method(#watchCurrentBalance, null),
        ).on(repository).thenThrow(DriftWrappedException(message: ''));

        final result = repository.watchCurrentBalance(
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
          Invocation.method(#watchCurrentBalance, null),
        ).on(repository).thenThrow(Exception());

        final result = repository.watchCurrentBalance(
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
}
