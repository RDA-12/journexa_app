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
  final parent = Account(
    code: '10.0000',
    name: 'asset',
    type: AccountType.asset,
    isSystemAccount: true,
  );
  final initialAccounts = [
    parent,
    Account(
      code: '10.0001',
      name: 'asset',
      type: AccountType.asset,
      parent: parent,
    ),
    Account(
      code: '10.0002',
      name: 'asset',
      type: AccountType.asset,
      parent: parent,
    ),
  ];
  final accounts = [
    Account(
      code: '10.0010',
      name: 'asset',
      type: AccountType.asset,
    ),
  ];

  late FirebaseFirestore fakeFirestore;
  late IAccountRepository repository;

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    for (final account in initialAccounts) {
      final doc = fakeFirestore.doc(
        'users/$userId/accounts/${account.code}',
      );
      await doc.set(FirestoreAccount.fromDomain(account).toJson());
    }
    repository = FirestoreAccountRepository(db: fakeFirestore);
  });

  tearDown(() async {
    await fakeFirestore.clearPersistence();
  });

  group('ensureSaved', () {
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

        expect(
          dbAccounts,
          [
            ...initialAccounts,
            ...accounts,
          ].map((it) => it.copyWith(parent: null)),
        );
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
            'error.code',
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
            'error.code',
            AppExceptionCode.internalException,
          ),
        );
      },
    );
  });

  group('save', () {
    final args = Account(
      code: '10.1000',
      name: 'new asset',
      type: AccountType.asset,
    );

    test('returns success and save correct account', () async {
      final expected = args;

      final result = await repository.save(
        userId,
        expected,
        traceId: traceId,
      );

      expect(result, const AppResult.success(null));

      final doc = fakeFirestore.doc('users/$userId/accounts/${expected.code}');
      final snapshot = await doc.get();
      expect(
        snapshot.data(),
        FirestoreAccount.fromDomain(expected).toJson(),
      );
    });

    test(
      'returns success and save correct account '
      'when parent provided',
      () async {
        final parent = initialAccounts[0];
        final expected = args.copyWith(parent: parent);

        final result = await repository.save(
          userId,
          expected,
          traceId: traceId,
        );
        expect(result, const AppResult.success(null));

        final doc = fakeFirestore.doc(
          'users/$userId/accounts/${expected.code}',
        );
        final snapshot = await doc.get();
        expect(
          snapshot.data(),
          FirestoreAccount.fromDomain(expected).toJson(),
        );
      },
    );

    test(
      'returns failure with accountAlreadyExists code '
      'when save existing name account',
      () async {
        final expected = args.copyWith(name: initialAccounts[0].name);

        final result = await repository.save(
          userId,
          expected,
          traceId: traceId,
        );

        expect(
          result,
          isA<AppResultFailure<Null>>().having(
            (e) => e.error.code,
            'error.code',
            AppExceptionCode.accountAlreadyExists,
          ),
        );
      },
    );

    test(
      'returns failure with accountAlreadyExists code '
      'when save existing code account',
      () async {
        final expected = args.copyWith(code: initialAccounts[0].code);

        final result = await repository.save(
          userId,
          expected,
          traceId: traceId,
        );

        expect(
          result,
          isA<AppResultFailure<Null>>().having(
            (e) => e.error.code,
            'error.code',
            AppExceptionCode.accountAlreadyExists,
          ),
        );
      },
    );

    test(
      'returns failure with serverException code '
      'when firestore throws FirebaseException',
      () async {
        final expected = args;
        final doc = fakeFirestore.doc(
          'users/$userId/accounts/${expected.code}',
        );
        whenCalling(
          Invocation.method(#set, null),
        ).on(doc).thenThrow(FirebaseException(plugin: 'firestore'));

        final result = await repository.save(
          userId,
          expected,
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
      'when firestore throws Exception',
      () async {
        final expected = args;
        final doc = fakeFirestore.doc(
          'users/$userId/accounts/${expected.code}',
        );
        whenCalling(
          Invocation.method(#set, null),
        ).on(doc).thenThrow(Exception('exception'));

        final result = await repository.save(
          userId,
          expected,
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

  group('getChildrenCountByParentCode', () {
    final parent = initialAccounts[0];

    test(
      'returns success with correct count '
      'when get children count by parent code',
      () async {
        const expectedChildrenCount = 5;
        for (var i = 1; i <= expectedChildrenCount; i++) {
          final child = Account(
            code: '${parent.code.split('.')[0]}.100$i',
            name: 'child $i',
            type: AccountType.asset,
            parent: parent,
          );
          final doc = fakeFirestore.doc('users/$userId/accounts/${child.code}');
          await doc.set(FirestoreAccount.fromDomain(child).toJson());
        }

        final result = await repository.getChildrenCountByParentCode(
          userId: userId,
          parentCode: parent.code,
          traceId: traceId,
        );

        expect(
          result,
          AppResult.success(
            expectedChildrenCount + initialAccounts.length - 1,
          ),
        );
      },
    );

    test(
      'returns failure with serverException code '
      'when firestore throws FirebaseException',
      () async {
        whenCalling(Invocation.method(#getChildrenCountByParentCode, null))
            .on(repository)
            .thenThrow(
              FirebaseException(plugin: 'firestore'),
            );

        final result = await repository.getChildrenCountByParentCode(
          userId: userId,
          parentCode: parent.code,
          traceId: traceId,
        );

        expect(
          result,
          isA<AppResultFailure<int>>().having(
            (e) => e.error.code,
            'error.code',
            AppExceptionCode.serverException,
          ),
        );
      },
    );

    test(
      'returns failure with internalException code '
      'when unexpected Exception thrown',
      () async {
        whenCalling(Invocation.method(#getChildrenCountByParentCode, null))
            .on(repository)
            .thenThrow(
              Exception(),
            );

        final result = await repository.getChildrenCountByParentCode(
          userId: userId,
          parentCode: parent.code,
          traceId: traceId,
        );

        expect(
          result,
          isA<AppResultFailure<int>>().having(
            (e) => e.error.code,
            'error.code',
            AppExceptionCode.internalException,
          ),
        );
      },
    );
  });

  group('getByParentCode', () {
    test(
      'returns success with correct accounts',
      () async {
        final expectedAccounts = initialAccounts
            .where(
              (it) => it.parent?.code == parent.code,
            )
            .toList();

        final result = await repository.getByParentCode(
          userId: userId,
          parentCode: parent.code,
          traceId: traceId,
        );

        expect(result, AppResult.success(expectedAccounts));
      },
    );

    test(
      'returns success with empty list '
      'when no accounts found for parent code',
      () async {
        final emptyParent = Account(
          code: '11.0000',
          name: 'not_exists',
          type: AccountType.asset,
          isSystemAccount: true,
        );
        final doc = fakeFirestore.doc(
          'users/$userId/accounts/${emptyParent.code}',
        );
        await doc.set(FirestoreAccount.fromDomain(emptyParent).toJson());

        final result = await repository.getByParentCode(
          userId: userId,
          parentCode: emptyParent.code,
          traceId: traceId,
        );

        expect(result, const AppResult.success(<Account>[]));
      },
    );

    test(
      'returns failure with accountNotFound code '
      'when parent data is not found',
      () async {
        final result = await repository.getByParentCode(
          userId: userId,
          parentCode: 'non-exist',
          traceId: traceId,
        );

        expect(
          result,
          isA<AppResultFailure<List<Account>>>().having(
            (e) => e.error.code,
            'error.code',
            AppExceptionCode.accountNotFound,
          ),
        );
      },
    );

    test(
      'returns failure with serverException code '
      'when firestore throws FirebaseException',
      () async {
        whenCalling(Invocation.method(#getByParentCode, null))
            .on(repository)
            .thenThrow(
              FirebaseException(plugin: 'firestore'),
            );

        final result = await repository.getByParentCode(
          userId: userId,
          parentCode: parent.code,
          traceId: traceId,
        );

        expect(
          result,
          isA<AppResultFailure<List<Account>>>().having(
            (e) => e.error.code,
            'error.code',
            AppExceptionCode.serverException,
          ),
        );
      },
    );

    test(
      'returns failure with internalException code '
      'when unexpected Exception thrown',
      () async {
        whenCalling(Invocation.method(#getByParentCode, null))
            .on(repository)
            .thenThrow(
              Exception(),
            );

        final result = await repository.getByParentCode(
          userId: userId,
          parentCode: parent.code,
          traceId: traceId,
        );

        expect(
          result,
          isA<AppResultFailure<List<Account>>>().having(
            (e) => e.error.code,
            'error.code',
            AppExceptionCode.internalException,
          ),
        );
      },
    );
  });
}
