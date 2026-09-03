import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:decimal/decimal.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/data/repositories/journal/firestore_journal.dart';
import 'package:journexa_app/data/repositories/transaction/firestore_transaction.dart';
import 'package:journexa_app/data/repositories/transaction/transaction_repository.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/journal.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:journexa_app/domain/repositories/i_transaction_repository.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

void main() {
  const userId = 'userId';
  const traceId = 'traceId';
  final initialTransactions = List.generate(5, (index) {
    return Transaction.income(
      id: 'id$index',
      walletId: 'wallet-1',
      incomeCategoryId: 'income-1',
      amount: Decimal.fromInt(100 * (index + 1)),
      date: DateTime.now(),
    );
  });

  late FirebaseFirestore fakeFirestore;
  late ITransactionRepository repository;

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    for (final tr in initialTransactions) {
      final doc = fakeFirestore.doc('users/$userId/transactions/${tr.id}');
      await doc.set(FirestoreTransaction.fromDomain(tr).toJson());
    }

    repository = FirestoreTransactionRepository(db: fakeFirestore);
  });

  tearDown(() async {
    await fakeFirestore.clearPersistence();
  });

  group('save', () {
    final transaction = Transaction.testIncome(
      amount: Decimal.fromInt(100),
      date: DateTime.now(),
    );
    final entry = JournalEntry(
      id: transaction.id,
      transactionDate: transaction.date,
      lines: [
        JournalEntryLine.fromAccount(
          account: Account.test(),
          amount: transaction.amount,
        ),
        JournalEntryLine.fromAccount(
          account: Account.test(AccountType.revenue),
          amount: transaction.amount,
        ),
      ],
      description: transaction.notes,
    );

    test(
      'returns succesn and save correct transaction, '
      'journal entry and its lines data',
      () async {
        final result = await repository.save(
          userId: userId,
          transaction: transaction,
          journalEntry: entry,
          traceId: traceId,
        );

        expect(result, const AppResult.success(null));

        final transactionSnapshot = await fakeFirestore
            .doc('users/$userId/transactions/${transaction.id}')
            .get();
        expect(transactionSnapshot.exists, true);
        expect(
          FirestoreTransaction.fromJson(transactionSnapshot.data()!),
          FirestoreTransaction.fromDomain(transaction),
        );

        final entrySnapshot = await fakeFirestore
            .doc('users/$userId/journalEntries/${entry.id}')
            .get();
        expect(entrySnapshot.exists, true);
        expect(
          FirestoreJournalEntry.fromJson(entrySnapshot.data()!),
          FirestoreJournalEntry.fromDomain(entry),
        );

        final linesSnapshot = await fakeFirestore
            .collection('users/$userId/journalEntries/${entry.id}/lines')
            .get();
        expect(linesSnapshot.docs.length, 2);
        expect(
          linesSnapshot.docs.map(
            (doc) => FirestoreJournalEntryLine.fromJson(doc.data()),
          ),
          entry.lines.map(FirestoreJournalEntryLine.fromDomain),
        );
      },
    );

    test(
      'returns failure with serverException code '
      'when firestore throws FirebaseException',
      () async {
        whenCalling(
          Invocation.method(#save, null),
        ).on(repository).thenThrow(FirebaseException(plugin: 'firestore'));

        final result = await repository.save(
          userId: userId,
          transaction: transaction,
          journalEntry: entry,
          traceId: traceId,
        );

        expect(
          result,
          isA<AppResultFailure<Null>>().having(
            (e) => e.error.code,
            'error.code',
            AppExceptionCode.serverException,
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
          userId: userId,
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

  group('getAll', () {
    test('returns success with correct transactions list', () async {
      final result = await repository.getAll(userId: userId, traceId: traceId);

      expect(result, AppResult.success(initialTransactions));
    });

    test(
      'returns failure with serverException code '
      'when firestore throws FirebaseException',
      () async {
        whenCalling(
          Invocation.method(#getAll, null),
        ).on(repository).thenThrow(FirebaseException(plugin: 'firestore'));

        final result = await repository.getAll(
          userId: userId,
          traceId: traceId,
        );

        expect(
          result,
          isA<AppResultFailure<List<Transaction>>>().having(
            (e) => e.error.code,
            'error.code',
            AppExceptionCode.serverException,
          ),
        );
      },
    );

    test(
      'returns failure with internalException code '
      'when repository throws Exception',
      () async {
        whenCalling(
          Invocation.method(#getAll, null),
        ).on(repository).thenThrow(Exception('exception'));

        final result = await repository.getAll(
          userId: userId,
          traceId: traceId,
        );

        expect(
          result,
          isA<AppResultFailure<List<Transaction>>>().having(
            (e) => e.error.code,
            'error.code',
            AppExceptionCode.internalException,
          ),
        );
      },
    );
  });
}
