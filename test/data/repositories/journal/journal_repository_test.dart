import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decimal/decimal.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/data/repositories/journal/firestore_journal.dart';
import 'package:journexa_app/data/repositories/journal/journal_repository.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/journal.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

void main() {
  const userId = 'userId';
  const traceId = 'traceId';
  final debitAccount = Account(
    code: '10.0001',
    name: 'asset 1',
    type: AccountType.asset,
  );
  final debitAccountBalance = AccountBalance(
    account: debitAccount,
    balance: Decimal.fromInt(10000),
  );

  late FirebaseFirestore fakeFirestore;
  late FirestoreJournalRepository repository;

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    repository = FirestoreJournalRepository(
      db: fakeFirestore,
    );
    final doc = fakeFirestore.doc(
      'users/$userId/account_balance/${debitAccount.code}',
    );
    await doc.set(
      FirestoreAccountBalance.fromDomain(debitAccountBalance).toJson(),
    );
  });

  tearDown(() async {
    await fakeFirestore.clearPersistence();
  });

  group(
    'getCurrentBalance',
    () {
      test(
        'returns success with correct mapped data',
        () async {
          final result = await repository.getCurrentBalance(
            userId: userId,
            accounts: [debitAccount],
            traceId: traceId,
          );

          expect(
            result,
            AppResult.success({debitAccount.code: debitAccountBalance}),
          );
        },
      );

      test(
        'returns success with zero balance for non-exists accounts',
        () async {
          final zeroBalanceAccount = Account(
            code: '10.1000',
            name: 'zero-balance',
            type: AccountType.asset,
          );

          final result = await repository.getCurrentBalance(
            userId: userId,
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
        },
      );

      test(
        'returns failure with serverException code '
        'when firestore throw FirebaseException',
        () async {
          final doc = fakeFirestore.doc(
            'users/$userId/account_balance/${debitAccount.code}',
          );
          whenCalling(
            Invocation.method(#get, null),
          ).on(doc).thenThrow(FirebaseException(plugin: 'firestore'));

          final result = await repository.getCurrentBalance(
            userId: userId,
            accounts: [debitAccount],
            traceId: traceId,
          );

          expect(
            result,
            isA<AppResultFailure<Map<String, AccountBalance>>>().having(
              (e) => e.error.code,
              'error.code',
              AppExceptionCode.serverException,
            ),
          );
        },
      );

      test(
        'returns failure with internalException code '
        'when firestore throw FirebaseException',
        () async {
          final doc = fakeFirestore.doc(
            'users/$userId/account_balance/${debitAccount.code}',
          );
          whenCalling(
            Invocation.method(#get, null),
          ).on(doc).thenThrow(Exception());

          final result = await repository.getCurrentBalance(
            userId: userId,
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
    },
  );

  group(
    'watchCurrentBalance',
    () {
      test(
        'emits success with correct mapped data',
        () async {
          final result = repository.watchCurrentBalance(
            userId: userId,
            traceId: traceId,
          );

          expect(
            result,
            emits(
              AppResult.success({
                debitAccount.code: debitAccountBalance.balance,
              }),
            ),
          );
        },
      );

      test(
        'emits failure with serverException code '
        'when firestore throw FirebaseException',
        () async {
          whenCalling(
            Invocation.method(#watchCurrentBalance, null),
          ).on(repository).thenThrow(FirebaseException(plugin: 'firestore'));

          final result = repository.watchCurrentBalance(
            userId: userId,
            traceId: traceId,
          );

          expect(
            result,
            emits(
              isA<AppResultFailure<Map<String, Decimal>>>().having(
                (e) => e.error.code,
                'error.code',
                AppExceptionCode.serverException,
              ),
            ),
          );
        },
      );

      test(
        'emits failure with internalException code '
        'when firestore throw Exception',
        () async {
          whenCalling(
            Invocation.method(#watchCurrentBalance, null),
          ).on(repository).thenThrow(Exception());

          final result = repository.watchCurrentBalance(
            userId: userId,
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
    },
  );
}
