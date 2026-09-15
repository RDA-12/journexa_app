import 'package:collection/collection.dart';
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

  final walletParent = SystemDefinedAccount.walletParent;
  final incomeParent = SystemDefinedAccount.incomeParent;
  final expenseParent = SystemDefinedAccount.expenseParent;

  final walletAccount = Account.sub(
    name: 'Wallet 1',
    parent: walletParent,
    currentChildrenCount: 0,
  );
  final wallet = Wallet(
    id: 'wallet-1',
    name: 'Wallet 1',
    account: walletAccount,
  );

  final wallet2Account = Account.sub(
    name: 'Wallet 2',
    parent: walletParent,
    currentChildrenCount: 1,
  );
  final wallet2 = Wallet(
    id: 'wallet-2',
    name: 'Wallet 2',
    account: wallet2Account,
  );

  final incomeCategoryAccount = Account.sub(
    name: 'Income Cat 1',
    parent: incomeParent,
    currentChildrenCount: 0,
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

  final wallet2Transaction = Transaction.income(
    id: 'wallet2-tx',
    walletId: wallet2.id,
    incomeCategoryId: incomeCategory.id,
    amount: Decimal.fromInt(500),
    date: DateTime(2026, 9, 7, 11),
  );

  final transferTransaction = Transaction.transfer(
    id: 'transfer-tx',
    sourceWalletId: wallet.id,
    destinationWalletId: wallet2.id,
    amount: Decimal.fromInt(50),
    fee: Decimal.zero,
    date: DateTime(2026, 9, 7, 11, 30),
  );

  late AppLocalDatabase db;
  late ITransactionRepository repository;

  setUp(() async {
    db = AppLocalDatabase.test();

    await db.into(db.accountDB).insert(walletParent.toDB());
    await db.into(db.accountDB).insert(incomeParent.toDB());
    await db.into(db.accountDB).insert(expenseParent.toDB());

    await db.into(db.accountDB).insert(walletAccount.toDB());
    await db.into(db.walletDB).insert(wallet.toDB());

    await db.into(db.accountDB).insert(wallet2Account.toDB());
    await db.into(db.walletDB).insert(wallet2.toDB());

    await db.into(db.accountDB).insert(incomeCategoryAccount.toDB());
    await db.into(db.incomeCategoryDB).insert(incomeCategory.toDB());

    for (final tr in [
      ...initialTransactions,
      wallet2Transaction,
      transferTransaction,
    ]) {
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
        expect(lineRows[0].accountCode, entry.lines[0].account.code.value);
        expect(lineRows[0].debit, entry.lines[0].debit);
        expect(lineRows[0].credit, entry.lines[0].credit);
        expect(lineRows[1].accountCode, entry.lines[1].account.code.value);
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
    test(
      'emits success with all transactions when no wallet filter is provided',
      () async {
        final result = repository.watch(traceId: traceId);

        expect(
          result,
          emits(
            AppResult.success(
              [
                ...initialTransactions,
                wallet2Transaction,
                transferTransaction,
              ].sorted((a, b) => b.date.compareTo(a.date)),
            ),
          ),
        );
      },
    );

    test(
      'emits success with filtered transactions when wallet filter is provided',
      () async {
        final result1 = repository.watch(traceId: traceId, wallet: wallet);
        final result2 = repository.watch(traceId: traceId, wallet: wallet2);

        expect(
          result1,
          emits(
            AppResult.success(
              [
                ...initialTransactions,
                transferTransaction,
              ].sorted((a, b) => b.date.compareTo(a.date)),
            ),
          ),
        );

        expect(
          result2,
          emits(
            AppResult.success(
              [
                wallet2Transaction,
                transferTransaction,
              ].sorted((a, b) => b.date.compareTo(a.date)),
            ),
          ),
        );
      },
    );

    test(
      'emits success with limited transactions when limit filter is provided',
      () async {
        final result = repository.watch(traceId: traceId, limit: 2);

        expect(
          result,
          emits(
            AppResult.success(
              [
                ...initialTransactions,
                wallet2Transaction,
                transferTransaction,
              ].sorted((a, b) => b.date.compareTo(a.date)).sublist(0, 2),
            ),
          ),
        );
      },
    );

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
