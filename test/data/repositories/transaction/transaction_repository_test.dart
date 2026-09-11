import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/data/database.dart';
import 'package:journexa_app/data/repositories/account/account.dart';
import 'package:journexa_app/data/repositories/income_category/income_category.dart';
import 'package:journexa_app/data/repositories/transaction/transaction.dart';
import 'package:journexa_app/data/repositories/wallet/wallet.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/domain/entities/journal.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/repositories/i_transaction_repository.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

void main() {
  const traceId = 'traceId';

  final assetParent = SystemDefinedAccount.rootAsset;
  final revenueParent = SystemDefinedAccount.rootRevenue;
  final expenseParent = SystemDefinedAccount.rootExpense;

  final walletAccount = Account(
    code: '10.0001',
    name: 'Wallet 1',
    type: AccountType.asset,
    parent: assetParent,
  );
  final wallet = Wallet(
    id: 'wallet-1',
    name: 'Wallet 1',
    account: walletAccount,
  );

  final incomeCategoryAccount = Account(
    code: '40.0001',
    name: 'Income Cat 1',
    type: AccountType.revenue,
    parent: revenueParent,
  );
  final incomeCategory = IncomeCategory(
    id: 'income-1',
    name: 'Income Cat 1',
    icon: 'icon',
    account: incomeCategoryAccount,
  );

  final initialTransactions = List.generate(5, (index) {
    return Transaction.income(
      id: 'id$index',
      walletId: wallet.id,
      incomeCategoryId: incomeCategory.id,
      amount: Decimal.fromInt(100 * (index + 1)),
      date: DateTime(2026, 9, 7, 10, index),
    );
  });

  late AppLocalDatabase db;
  late ITransactionRepository repository;

  setUp(() async {
    db = AppLocalDatabase.test();

    await db.into(db.accountDB).insert(assetParent.toDB());
    await db.into(db.accountDB).insert(revenueParent.toDB());
    await db.into(db.accountDB).insert(expenseParent.toDB());

    await db.into(db.accountDB).insert(walletAccount.toDB());
    await db.into(db.walletDB).insert(wallet.toDB());

    await db.into(db.accountDB).insert(incomeCategoryAccount.toDB());
    await db.into(db.incomeCategoryDB).insert(incomeCategory.toDB());

    for (final tr in initialTransactions) {
      await db.into(db.transactionDB).insert(tr.toDB());
    }

    repository = DriftTransactionRepository(db: db);
  });

  tearDown(() async {
    await db.delete(db.journalEntryLineDB).go();
    await db.delete(db.journalEntryDB).go();
    await db.delete(db.transactionDB).go();
    await db.delete(db.incomeCategoryDB).go();
    await db.delete(db.expenseCategoryDB).go();
    await db.delete(db.walletDB).go();
    await db.delete(db.accountDB).go();
    await db.close();
  });

  group('save', () {
    final transaction = Transaction.income(
      id: 'new-tx',
      walletId: wallet.id,
      incomeCategoryId: incomeCategory.id,
      amount: Decimal.fromInt(100),
      date: DateTime(2026, 9, 7, 12),
      notes: 'New tx note',
    );
    final entry = JournalEntry(
      id: transaction.id,
      transactionDate: transaction.date,
      lines: [
        JournalEntryLine.fromAccount(
          account: walletAccount,
          amount: transaction.amount,
        ),
        JournalEntryLine.fromAccount(
          account: incomeCategoryAccount,
          amount: transaction.amount,
        ),
      ],
      description: transaction.notes,
    );

    test(
      'returns success and save correct transaction, '
      'journal entry and its lines data',
      () async {
        final result = await repository.save(
          transaction: transaction,
          journalEntry: entry,
          traceId: traceId,
        );

        expect(result, const AppResult.success(null));

        final txRow = await (db.select(
          db.transactionDB,
        )..where((t) => t.id.equals(transaction.id))).getSingle();
        expect(txRow.toDomain(), transaction);

        final entryRow = await (db.select(
          db.journalEntryDB,
        )..where((e) => e.id.equals(entry.id))).getSingle();
        expect(entryRow.id, entry.id);
        expect(entryRow.transactionDate, entry.transactionDate);
        expect(entryRow.notes, entry.description);

        final lineRows = await (db.select(
          db.journalEntryLineDB,
        )..where((l) => l.journalId.equals(entry.id))).get();
        expect(lineRows.length, 2);
        expect(lineRows[0].accountCode, entry.lines[0].account.code);
        expect(lineRows[0].debit, entry.lines[0].debit);
        expect(lineRows[0].credit, entry.lines[0].credit);
        expect(lineRows[1].accountCode, entry.lines[1].account.code);
        expect(lineRows[1].debit, entry.lines[1].debit);
        expect(lineRows[1].credit, entry.lines[1].credit);
      },
    );

    test(
      'returns failure with internalException code '
      'when db throws DriftWrappedException',
      () async {
        whenCalling(
          Invocation.method(#save, null),
        ).on(repository).thenThrow(DriftWrappedException(message: ''));

        final result = await repository.save(
          transaction: transaction,
          journalEntry: entry,
          traceId: traceId,
        );

        expect(
          result,
          isA<AppResultFailure<Null>>().having(
            (e) => e.error.code,
            'error.code',
            AppExceptionCode.internalException,
          ),
        );
      },
    );

    test(
      'returns failure with internalException code '
      'when repository throws Exception',
      () async {
        whenCalling(
          Invocation.method(#save, null),
        ).on(repository).thenThrow(Exception('exception'));

        final result = await repository.save(
          transaction: transaction,
          journalEntry: entry,
          traceId: traceId,
        );

        expect(
          result,
          isA<AppResultFailure<Null>>().having(
            (e) => e.error.code,
            'error.code',
            AppExceptionCode.internalException,
          ),
        );
      },
    );
  });

  group('watch', () {
    test('emits success with correct transactions list', () async {
      final result = repository.watch(traceId: traceId);

      expect(result, emits(AppResult.success(initialTransactions)));
    });

    test(
      'emits failure with internalException code '
      'when db emits DriftWrappedException',
      () async {
        whenCalling(
          Invocation.method(#watch, null),
        ).on(repository).thenThrow(DriftWrappedException(message: ''));

        final result = repository.watch(
          traceId: traceId,
        );

        expect(
          result,
          emits(
            isA<AppResultFailure<List<Transaction>>>().having(
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
          Invocation.method(#watch, null),
        ).on(repository).thenThrow(Exception('exception'));

        final result = repository.watch(
          traceId: traceId,
        );

        expect(
          result,
          emits(
            isA<AppResultFailure<List<Transaction>>>().having(
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
