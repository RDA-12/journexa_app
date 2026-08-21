import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/data/repositories/account/account.dart';
import 'package:journexa_app/data/repositories/wallet/wallet.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/repositories/i_wallet_respository.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

void main() {
  const userId = 'userId';
  const traceId = 'traceId';

  final parent = kSystemDefinedAccounts.firstWhere(
    (it) => it.code == '10.0000',
  );
  final initialWallets = List.generate(5, (index) {
    return Wallet(
      id: '$index',
      name: 'wallet $index',
      account: Account(
        code: '10.000${index + 1}',
        name: 'wallet $index',
        type: AccountType.asset,
        parent: parent,
      ),
    );
  });

  late FirebaseFirestore fakeFirestore;
  late IWalletRepository repository;

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    final parentFirestore = FirestoreAccount.fromDomain(parent);
    final parentDoc = fakeFirestore.doc(
      'users/$userId/accounts/${parent.code}',
    );
    await parentDoc.set(parentFirestore.toJson());
    for (final wallet in initialWallets) {
      final walletFirestore = FirestoreWallet.fromDomain(wallet);
      final walletDoc = fakeFirestore.doc('users/$userId/wallets/${wallet.id}');
      await walletDoc.set(walletFirestore.toJson());
      final walletAccount = FirestoreAccount.fromDomain(wallet.account);
      final accountDoc = fakeFirestore.doc(
        'users/$userId/accounts/${wallet.account.code}',
      );
      await accountDoc.set(walletAccount.toJson());
    }

    repository = FirestoreWalletRepository(db: fakeFirestore);
  });

  tearDown(() async {
    await fakeFirestore.clearPersistence();
  });

  group('save', () {
    final newWallet = Wallet(
      id: 'new',
      name: 'new wallet',
      account: Account(
        code: '10.1000',
        name: 'new wallet',
        type: AccountType.asset,
        parent: parent,
      ),
    );

    test(
      'returns success and save correct Wallet and Account',
      () async {
        final result = await repository.save(
          userId: userId,
          wallet: newWallet,
          traceId: traceId,
        );

        expect(result, const AppResult.success(null));

        final walletDocRef = fakeFirestore.doc(
          'users/$userId/wallets/${newWallet.id}',
        );
        final walletSnapshot = await walletDocRef.get();
        expect(
          walletSnapshot.data(),
          FirestoreWallet.fromDomain(newWallet).toJson(),
        );

        final accountDocRef = fakeFirestore.doc(
          'users/$userId/accounts/${newWallet.account.code}',
        );
        final accountSnapshot = await accountDocRef.get();
        final firestoreAccount = FirestoreAccount.fromDomain(newWallet.account);
        expect(accountSnapshot.data(), firestoreAccount.toJson());
      },
    );

    test(
      'returns failure with walletAlreadyExists '
      'when wallet with same name exists',
      () async {
        final expected = newWallet.copyWith(
          name: initialWallets.first.name,
          account: newWallet.account.copyWith(name: initialWallets.first.name),
        );

        final result = await repository.save(
          userId: userId,
          wallet: expected,
          traceId: traceId,
        );

        expect(
          result,
          isA<AppResultFailure<Null>>().having(
            (e) => e.error.code,
            'error.code',
            AppExceptionCode.walletNameAlreadyExists,
          ),
        );
      },
    );

    test(
      'returns failure with serverException code '
      'when firestore throws FirebaseException',
      () async {
        whenCalling(Invocation.method(#save, null))
            .on(repository)
            .thenThrow(
              FirebaseException(plugin: 'firestore'),
            );

        final result = await repository.save(
          userId: userId,
          wallet: newWallet,
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
        whenCalling(
          Invocation.method(#save, null),
        ).on(repository).thenThrow(Exception());

        final result = await repository.save(
          userId: userId,
          wallet: newWallet,
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
    test(
      'returns success with correct Wallets',
      () async {
        final result = await repository.getAll(
          userId: userId,
          traceId: traceId,
        );

        expect(result, AppResult.success(initialWallets));
      },
    );

    test(
      'returns success with correct Wallets when query provided',
      () async {
        final expectedWallet = Wallet(
          id: 'expected',
          name: 'expected name',
          account: Account(
            code: '10.1000',
            name: 'expected name',
            type: AccountType.asset,
            parent: parent,
          ),
        );
        final walletDoc = fakeFirestore.doc(
          'users/$userId/wallets/${expectedWallet.id}',
        );
        await walletDoc.set(
          FirestoreWallet.fromDomain(expectedWallet).toJson(),
        );
        final accountDoc = fakeFirestore.doc(
          'users/$userId/accounts/${expectedWallet.account.code}',
        );
        await accountDoc.set(
          FirestoreAccount.fromDomain(expectedWallet.account).toJson(),
        );

        final result = await repository.getAll(
          userId: userId,
          query: 'expected',
          traceId: traceId,
        );

        expect(result, AppResult.success([expectedWallet]));
      },
    );

    test(
      'returns failure with serverException code '
      'when firestore throws FirebaseException',
      () async {
        whenCalling(Invocation.method(#getAll, null))
            .on(repository)
            .thenThrow(
              FirebaseException(plugin: 'firestore'),
            );

        final result = await repository.getAll(
          userId: userId,
          traceId: traceId,
        );

        expect(
          result,
          isA<AppResultFailure<List<Wallet>>>().having(
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
        whenCalling(
          Invocation.method(#getAll, null),
        ).on(repository).thenThrow(Exception());

        final result = await repository.getAll(
          userId: userId,
          traceId: traceId,
        );

        expect(
          result,
          isA<AppResultFailure<List<Wallet>>>().having(
            (e) => e.error.code,
            'error.code',
            AppExceptionCode.internalException,
          ),
        );
      },
    );
  });

  group('delete', () {
    test(
      'returns success and delete correct Wallet and the Account',
      () async {
        final deletedWallet = initialWallets.first;

        final result = await repository.delete(
          userId: userId,
          wallet: deletedWallet,
          traceId: traceId,
        );

        expect(result, const AppResult.success(null));

        final walletDocRef = fakeFirestore.doc(
          'users/$userId/wallets/${deletedWallet.id}',
        );
        final walletSnapshot = await walletDocRef.get();
        expect(walletSnapshot.exists, isFalse);

        final accountDocRef = fakeFirestore.doc(
          'users/$userId/accounts/${deletedWallet.account.code}',
        );
        final accountSnapshot = await accountDocRef.get();
        expect(accountSnapshot.exists, isFalse);
      },
    );

    test(
      'do nothing when wallet does not exist',
      () async {
        final nonExistentWallet = Wallet(
          id: 'non-existent',
          name: 'non-existent',
          account: Account(
            code: '10.0100',
            name: 'non-existent',
            type: AccountType.asset,
            parent: parent,
          ),
        );

        final result = await repository.delete(
          userId: userId,
          wallet: nonExistentWallet,
          traceId: traceId,
        );

        expect(result, const AppResult.success(null));

        final walletDocRef = fakeFirestore.doc(
          'users/$userId/wallets/${nonExistentWallet.id}',
        );
        final walletSnapshot = await walletDocRef.get();
        expect(walletSnapshot.exists, isFalse);

        final accountDocRef = fakeFirestore.doc(
          'users/$userId/accounts/${nonExistentWallet.account.code}',
        );
        final accountSnapshot = await accountDocRef.get();
        expect(accountSnapshot.exists, isFalse);
      },
    );

    test(
      'returns failure with serverException '
      'when firestore throws FirebaseException',
      () async {
        whenCalling(
          Invocation.method(#delete, null),
        ).on(repository).thenThrow(FirebaseException(plugin: 'firestore'));

        final result = await repository.delete(
          userId: userId,
          wallet: initialWallets.first,
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
      'when firestore throws Exception',
      () async {
        whenCalling(
          Invocation.method(#delete, null),
        ).on(repository).thenThrow(Exception());

        final result = await repository.delete(
          userId: userId,
          wallet: initialWallets.first,
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

  group('update', () {
    final updatedWallet = initialWallets.first.update(name: 'new name');
    test(
      'returns success when succeeded',
      () async {
        final result = await repository.update(
          userId: userId,
          updatedWallet: updatedWallet,
          traceId: traceId,
        );

        expect(result, const AppResult.success(null));
      },
    );

    test(
      'update both Wallet and Account',
      () async {
        await repository.update(
          userId: userId,
          updatedWallet: updatedWallet,
          traceId: traceId,
        );

        final walletDoc = await fakeFirestore
            .doc('users/$userId/wallets/${updatedWallet.id}')
            .get();
        expect(
          walletDoc.data(),
          FirestoreWallet.fromDomain(updatedWallet).toJson(),
        );

        final accountDoc = await fakeFirestore
            .doc('users/$userId/accounts/${updatedWallet.account.code}')
            .get();
        expect(
          accountDoc.data(),
          FirestoreAccount.fromDomain(updatedWallet.account).toJson(),
        );
      },
    );

    test(
      'returns failure with serverException '
      'when firestore throws FirebaseException',
      () async {
        whenCalling(
          Invocation.method(#update, null),
        ).on(repository).thenThrow(FirebaseException(plugin: 'firestore'));

        final result = await repository.update(
          userId: userId,
          updatedWallet: updatedWallet,
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
      'when firestore throws Exception',
      () async {
        whenCalling(
          Invocation.method(#update, null),
        ).on(repository).thenThrow(Exception());

        final result = await repository.update(
          userId: userId,
          updatedWallet: updatedWallet,
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
}
