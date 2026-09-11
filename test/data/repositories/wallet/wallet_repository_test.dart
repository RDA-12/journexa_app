import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/data/database.dart';
import 'package:journexa_app/data/repositories/account/account.dart';
import 'package:journexa_app/data/repositories/wallet/wallet.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/repositories/i_wallet_respository.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

void main() {
  const traceId = 'traceId';

  final parentAccount = SystemDefinedAccount.walletParent;
  final initialWallets = List.generate(5, (index) {
    return Wallet(
      id: 'wallet_id_$index',
      name: 'Wallet $index',
      account: Account.sub(
        parent: parentAccount,
        name: 'Wallet $index',
        currentChildrenCount: index,
      ),
    );
  });

  late AppLocalDatabase db;
  late IWalletRepository repository;

  setUp(() async {
    db = AppLocalDatabase.test();
    await db.into(db.accountDB).insert(parentAccount.toDB());
    for (final wallet in initialWallets) {
      await db.into(db.walletDB).insert(wallet.toDB());
      await db.into(db.accountDB).insert(wallet.account.toDB());
    }

    repository = DriftWalletRepository(db: db);
  });

  tearDown(() async {
    await db.delete(db.walletDB).go();
    await db.delete(db.accountDB).go();
    await db.close();
  });

  group('save', () {
    final newWallet = Wallet(
      id: 'completely-new',
      name: 'completely new',
      account: Account.sub(
        parent: parentAccount,
        name: 'completely new',
        currentChildrenCount: initialWallets.length,
      ),
    );

    test('returns success and save correct wallet and account', () async {
      final result = await repository.save(
        traceId: traceId,
        wallet: newWallet,
      );

      expect(result, const AppResult.success(null));

      final statement = db.select(db.walletDB).join([
        leftOuterJoin(
          db.accountDB,
          db.accountDB.code.equalsExp(db.walletDB.accountCode),
        ),
      ])..where(db.walletDB.id.equals(newWallet.id));
      final row = await statement.getSingle();
      expect(
        row
            .readTable(db.walletDB)
            .toDomain(
              account: row
                  .readTable(db.accountDB)
                  .toDomain(parent: SystemDefinedAccount.walletParent),
            ),
        newWallet,
      );
    });

    test(
      'returns failure with walletNameAlreadyExists code '
      'when saving existing wallet name',
      () async {
        final existingName = initialWallets.first.name;

        final result = await repository.save(
          traceId: traceId,
          wallet: newWallet.copyWith(
            name: existingName,
            account: newWallet.account.copyWith(
              name: existingName,
            ),
          ),
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
      'returns failure with internalException code '
      'when db throws DriftWrapperException',
      () async {
        whenCalling(
          Invocation.method(#save, null),
        ).on(repository).thenThrow(DriftWrappedException(message: ''));

        final result = await repository.save(
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

    test(
      'returns failure with internalException code '
      'when db throws Exception',
      () async {
        whenCalling(
          Invocation.method(#save, null),
        ).on(repository).thenThrow(Exception());

        final result = await repository.save(
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

  group('watch', () {
    test(
      'emits success with correct wallets',
      () async {
        final result = repository.watch(
          traceId: traceId,
        );

        expect(result, emits(AppResult.success(initialWallets)));
      },
    );

    test(
      'emits success with correct wallets when query provided',
      () async {
        final expectedWallet = Wallet(
          id: 'expected',
          name: 'expected name',
          account: Account.sub(
            name: 'expected name',
            parent: parentAccount,
            currentChildrenCount: 100,
          ),
        );
        await db.into(db.walletDB).insert(expectedWallet.toDB());
        await db.into(db.accountDB).insert(expectedWallet.account.toDB());

        final result = repository.watch(
          query: 'expected',
          traceId: traceId,
        );

        expect(result, emits(AppResult.success([expectedWallet])));
      },
    );

    test(
      'emits success with correct wallets when isDeleted provided',
      () async {
        final expectedWallet = Wallet(
          id: 'expected',
          name: 'expected name',
          account: Account.sub(
            name: 'expected name',
            parent: parentAccount,
            currentChildrenCount: 100,
          ),
        );
        await db
            .into(db.walletDB)
            .insert(
              expectedWallet.toDB().copyWith(
                isDeleted: const Value(true),
              ),
            );
        await db
            .into(db.accountDB)
            .insert(
              expectedWallet.account.toDB().copyWith(
                isDeleted: const Value(true),
              ),
            );

        final result = repository.watch(
          isDeleted: false,
          traceId: traceId,
        );

        expect(result, emits(AppResult.success(initialWallets)));

        final result2 = repository.watch(
          isDeleted: true,
          traceId: traceId,
        );

        expect(result2, emits(AppResult.success([expectedWallet])));
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
            isA<AppResultFailure<List<Wallet>>>().having(
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
      'when db stream emits exception',
      () async {
        whenCalling(
          Invocation.method(#watch, null),
        ).on(repository).thenThrow(Exception());

        final result = repository.watch(
          traceId: traceId,
        );

        expect(
          result,
          emits(
            isA<AppResultFailure<List<Wallet>>>().having(
              (e) => e.error.code,
              'error.code',
              AppExceptionCode.internalException,
            ),
          ),
        );
      },
    );
  });

  group('delete', () {
    test(
      'returns success and set isDeleted to true '
      'for correct Wallet and the Account',
      () async {
        final deletedWallet = initialWallets.first;

        final result = await repository.delete(
          wallet: deletedWallet,
          traceId: traceId,
        );

        expect(result, const AppResult.success(null));

        final statement = db.select(db.walletDB).join([
          leftOuterJoin(
            db.accountDB,
            db.accountDB.code.equalsExp(db.walletDB.accountCode),
          ),
        ])..where(db.walletDB.id.equals(deletedWallet.id));
        final row = await statement.getSingle();

        expect(row.readTable(db.walletDB).isDeleted, isTrue);
        expect(row.readTable(db.accountDB).isDeleted, isTrue);
      },
    );

    test(
      'do nothing when wallet does not exist',
      () async {
        final nonExistentWallet = Wallet(
          id: 'non-existent',
          name: 'non-existent',
          account: Account.sub(
            name: 'non-existent',
            parent: parentAccount,
            currentChildrenCount: 100,
          ),
        );

        final result = await repository.delete(
          wallet: nonExistentWallet,
          traceId: traceId,
        );

        expect(result, const AppResult.success(null));

        final statement = db.select(db.walletDB).join([
          leftOuterJoin(
            db.accountDB,
            db.accountDB.code.equalsExp(db.walletDB.accountCode),
          ),
        ])..where(db.walletDB.id.equals(nonExistentWallet.id));
        final row = await statement.getSingleOrNull();

        expect(row, null);
      },
    );

    test(
      'returns failure with internalException '
      'when db throws DriftWrappedException',
      () async {
        whenCalling(
          Invocation.method(#delete, null),
        ).on(repository).thenThrow(DriftWrappedException(message: ''));

        final result = await repository.delete(
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

    test(
      'returns failure with internalException '
      'when db throws Exception',
      () async {
        whenCalling(
          Invocation.method(#delete, null),
        ).on(repository).thenThrow(Exception());

        final result = await repository.delete(
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
          updatedWallet: updatedWallet,
          traceId: traceId,
        );

        final statement = db.select(db.walletDB).join([
          leftOuterJoin(
            db.accountDB,
            db.accountDB.code.equalsExp(db.walletDB.accountCode),
          ),
        ])..where(db.walletDB.id.equals(updatedWallet.id));
        final row = await statement.getSingle();
        final account = row
            .readTable(db.accountDB)
            .toDomain(parent: SystemDefinedAccount.walletParent);
        final wallet = row.readTable(db.walletDB).toDomain(account: account);
        expect(wallet, updatedWallet);
      },
    );

    test(
      'returns failure with internalException '
      'when db throws DriftWrappedException',
      () async {
        whenCalling(
          Invocation.method(#update, null),
        ).on(repository).thenThrow(DriftWrappedException(message: ''));

        final result = await repository.update(
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

    test(
      'returns failure with internalException '
      'when db throws Exception',
      () async {
        whenCalling(
          Invocation.method(#update, null),
        ).on(repository).thenThrow(Exception());

        final result = await repository.update(
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
