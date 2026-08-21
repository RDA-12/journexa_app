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

  final initialWallets = List.generate(5, (index) {
    return Wallet(
      id: '$index',
      name: 'wallet $index',
      account: Account(
        code: '10.000${index + 1}',
        name: 'wallet $index',
        type: AccountType.asset,
      ),
    );
  });

  late FirebaseFirestore fakeFirestore;
  late IWalletRepository repository;

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
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
        expect(
          accountSnapshot.data(),
          FirestoreAccount.fromDomain(newWallet.account).toJson(),
        );
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
}
