import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/data/repositories/account/account.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/repositories/i_account_repository.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

void main() {
  const userId = 'userId';
  const traceId = 'trace';

  late FirebaseFirestore fakeFirestore;
  late IAccountRepository repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = FirestoreAccountRepository(db: fakeFirestore);
  });

  tearDown(() async {
    await fakeFirestore.clearPersistence();
  });

  group('ensureSaved', () {
    final initialAccounts = [
      Account(
        code: '10.0001',
        name: 'asset',
        type: AccountType.asset,
      ),
      Account(
        code: '10.0002',
        name: 'asset',
        type: AccountType.asset,
      ),
    ];
    final accounts = [
      Account(
        code: '10.0000',
        name: 'asset',
        type: AccountType.asset,
      ),
    ];

    setUp(() async {
      for (final account in initialAccounts) {
        final doc = fakeFirestore.doc(
          'users/$userId/accounts/${account.code}',
        );
        await doc.set(FirestoreAccount.fromDomain(account).toJson());
      }
    });

    test(
      'returns success when all accounts saved',
      () async {
        final result = await repository.ensureSaved(
          userId,
          accounts: accounts,
          traceId: traceId,
        );

        expect(result, const AppResult.success(null));

        final colRef = fakeFirestore.collection('users/$userId/accounts');
        final data = await colRef.get();
        final dbAccounts = <Account>[];
        for (final account in data.docs) {
          dbAccounts.add(
            FirestoreAccount.fromJson(account.data()).toDomain(),
          );
        }

        expect(dbAccounts, [...initialAccounts, ...accounts]);
      },
    );

    test(
      'returns failure with serverException code '
      'when firestore throws unexpected Exception',
      () async {
        for (final account in accounts) {
          final doc = fakeFirestore.doc(
            'users/$userId/accounts/${account.code}',
          );
          whenCalling(
            Invocation.method(#get, null),
          ).on(doc).thenThrow(FirebaseException(plugin: 'firestore'));
        }

        final result = await repository.ensureSaved(
          userId,
          accounts: accounts,
          traceId: traceId,
        );

        expect(
          result,
          isA<AppResultFailure<Null>>().having(
            (e) => e.error.code,
            'code',
            AppExceptionCode.serverException,
          ),
        );
      },
    );

    test(
      'returns failure with internalException '
      'when unexpected Exception thrown',
      () async {
        final doc = fakeFirestore.doc(
          'users/$userId/accounts/${accounts[0].code}',
        );
        whenCalling(
          Invocation.method(#get, null),
        ).on(doc).thenThrow(Exception('exeption'));

        final result = await repository.ensureSaved(
          userId,
          accounts: accounts,
          traceId: traceId,
        );

        expect(
          result,
          isA<AppResultFailure<Null>>().having(
            (e) => e.error.code,
            'code',
            AppExceptionCode.internalException,
          ),
        );
      },
    );
  });
}
