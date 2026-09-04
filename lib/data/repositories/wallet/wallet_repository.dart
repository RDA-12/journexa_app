import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/data/repositories/account/account.dart';
import 'package:journexa_app/data/repositories/wallet/firestore_wallet.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/repositories/i_wallet_respository.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:rxdart/rxdart.dart';

/// Firestore implementation of [IWalletRepository]
@LazySingleton(as: IWalletRepository)
class FirestoreWalletRepository with Loggable implements IWalletRepository {
  /// Creates new [FirestoreWalletRepository]
  FirestoreWalletRepository({required this._db});

  final FirebaseFirestore _db;

  @override
  String get logTag => 'FirestoreWalletRepository';

  @override
  Future<AppResult<Null>> save({
    required String userId,
    required Wallet wallet,
    required String traceId,
  }) async {
    try {
      maybeThrowException(this, Invocation.method(#save, null));
      logInfo(
        'Starts checking wallet name',
        traceId: traceId,
        extras: {'name': wallet.name},
      );
      final walletsCol = _db.collection('users/$userId/wallets');
      final walletsQuery = walletsCol.where('name', isEqualTo: wallet.name);
      final walletsSnaps = await walletsQuery.get();
      if (walletsSnaps.docs.isNotEmpty) {
        logInfo('Name already exists', traceId: traceId);
        return const AppResult.failure(
          AppException(
            'Wallet name already exists',
            code: AppExceptionCode.walletNameAlreadyExists,
          ),
        );
      }

      final walletFirestore = FirestoreWallet.fromDomain(wallet);
      final accountFirestore = FirestoreAccount.fromDomain(wallet.account);
      logInfo(
        'Name not yet exists. Starts batch writes wallet and account',
        traceId: traceId,
        extras: {
          'wallet': walletFirestore.toJson(),
          'account': accountFirestore.toJson(),
        },
      );
      final walletDoc = _db.doc('users/$userId/wallets/${wallet.id}');
      final accountDoc = _db.doc(
        'users/$userId/accounts/${wallet.account.code}',
      );
      final batch = _db.batch()
        ..set(walletDoc, walletFirestore.toJson())
        ..set(accountDoc, accountFirestore.toJson());
      await batch.commit();
      logInfo(
        'Successfully written wallet and account to database',
        traceId: traceId,
      );
      return const AppResult.success(null);
    } on FirebaseException catch (e) {
      logError('$e', traceId: traceId, error: e);
      return AppResult.failure(
        AppException('$e', code: AppExceptionCode.serverException),
      );
    } on Exception catch (e, st) {
      logError('$e', traceId: traceId, error: e, stackTrace: st);
      return AppResult.failure(
        AppException('$e', code: AppExceptionCode.internalException),
      );
    }
  }

  @override
  Stream<AppResult<List<Wallet>>> watch({
    required String userId,
    required String traceId,
    String? query,
    bool? isDeleted,
  }) {
    logInfo(
      'Constructing streams for wallets and its accounts',
      traceId: traceId,
      extras: {'query': query},
    );
    Query<Map<String, Object?>> walletsQuery = _db.collection(
      'users/$userId/wallets',
    );
    Query<Map<String, Object?>> accountsQuery = _db.collection(
      'users/$userId/accounts',
    );
    if (query != null) {
      walletsQuery = walletsQuery
          .where('nameLower', isGreaterThanOrEqualTo: query)
          .where('nameLower', isLessThanOrEqualTo: '$query~');
      accountsQuery = accountsQuery
          .where('nameLower', isGreaterThanOrEqualTo: query)
          .where('nameLower', isLessThanOrEqualTo: '$query~');
    }
    if (isDeleted != null) {
      walletsQuery = walletsQuery.where(
        'isDeleted',
        isEqualTo: isDeleted,
      );
      accountsQuery = accountsQuery.where(
        'isDeleted',
        isEqualTo: isDeleted,
      );
    }
    final walletsStream = walletsQuery.snapshots();
    final accountsStream = accountsQuery.snapshots();
    logInfo(
      'Streams constructed. Return combined streams',
      traceId: traceId,
    );
    return CombineLatestStream.combine2(
      walletsStream,
      accountsStream,
      (walletSnap, accountSnap) {
        maybeThrowException(this, Invocation.method(#watch, null));
        logInfo(
          'Either wallet or account changed. '
          'Starts constructing wallets',
          traceId: traceId,
        );
        final walletDocs = walletSnap.docs;
        final accountDocs = accountSnap.docs;
        final result = <Wallet>[];
        for (final walletDoc in walletDocs) {
          final firestoreWallet = FirestoreWallet.fromJson(
            walletDoc.data(),
          );
          final accountDoc = accountDocs.firstWhereOrNull((it) {
            return it.data()['code'] == firestoreWallet.accountCode;
          });
          if (accountDoc == null) {
            logWarning(
              'Account for wallet ${firestoreWallet.id} not found',
              traceId: traceId,
              extras: {
                'walletId': firestoreWallet.id,
              },
            );
            continue;
          }
          final firestoreAccount = FirestoreAccount.fromJson(
            accountDoc.data(),
          );
          final wallet = firestoreWallet.toDomain(
            firestoreAccount.toDomain().copyWith(
              parent: SystemDefinedAccount.rootAsset,
            ),
          );
          result.add(wallet);
        }
        return AppResult.success(result);
      },
    ).onErrorReturnWith((err, st) {
      logError('$err', traceId: traceId, error: err, stackTrace: st);
      if (err is FirebaseException) {
        return AppResult.failure(
          AppException('$err', code: AppExceptionCode.serverException),
        );
      }
      return AppResult.failure(
        AppException('$err', code: AppExceptionCode.internalException),
      );
    });
  }

  @override
  Future<AppResult<Null>> delete({
    required String userId,
    required Wallet wallet,
    required String traceId,
  }) async {
    try {
      maybeThrowException(this, Invocation.method(#delete, null));
      final walletFirestore = FirestoreWallet.fromDomain(wallet);
      final accountFirestore = FirestoreAccount.fromDomain(wallet.account);
      logInfo(
        'Starts deleting wallet',
        traceId: traceId,
        extras: {
          'wallet': walletFirestore.toJson(),
          'account': accountFirestore.toJson(),
        },
      );

      final walletRef = _db.doc('users/$userId/wallets/${wallet.id}');
      final walletSnap = await walletRef.get();
      final walletExists = walletSnap.exists;
      final accountRef = _db.doc(
        'users/$userId/accounts/${wallet.account.code}',
      );
      final accountSnap = await accountRef.get();
      final accountExists = accountSnap.exists;
      final batch = _db.batch();
      if (walletExists) {
        batch.set(
          walletRef,
          walletFirestore.copyWith(isDeleted: true).toJson(),
        );
      }
      if (accountExists) {
        batch.set(
          accountRef,
          accountFirestore.copyWith(isDeleted: true).toJson(),
        );
      }
      await batch.commit();
      logInfo(
        'Successfully deleted wallet and account',
        traceId: traceId,
      );
      return const AppResult.success(null);
    } on FirebaseException catch (e) {
      logError('$e', traceId: traceId, error: e);
      return AppResult.failure(
        AppException('$e', code: AppExceptionCode.serverException),
      );
    } on Exception catch (e, st) {
      logError('$e', traceId: traceId, error: e, stackTrace: st);
      return AppResult.failure(
        AppException('$e', code: AppExceptionCode.internalException),
      );
    }
  }

  @override
  Future<AppResult<Null>> update({
    required String userId,
    required Wallet updatedWallet,
    required String traceId,
  }) async {
    try {
      maybeThrowException(this, Invocation.method(#update, null));
      final walletFirestore = FirestoreWallet.fromDomain(updatedWallet);
      final accountFirestore = FirestoreAccount.fromDomain(
        updatedWallet.account,
      );

      logInfo(
        'Starts updating wallet',
        traceId: traceId,
        extras: {
          'wallet': walletFirestore.toJson(),
          'account': accountFirestore.toJson(),
        },
      );
      final batch = _db.batch();
      final walletRef = _db.doc('users/$userId/wallets/${updatedWallet.id}');
      batch.set(walletRef, walletFirestore.toJson());
      final accountRef = _db.doc(
        'users/$userId/accounts/${updatedWallet.account.code}',
      );
      batch.set(accountRef, accountFirestore.toJson());
      await batch.commit();
      logInfo(
        'Successfully updated wallet and account',
        traceId: traceId,
      );
      return const AppResult.success(null);
    } on FirebaseException catch (e) {
      logError('$e', traceId: traceId, error: e);
      return AppResult.failure(
        AppException('$e', code: AppExceptionCode.serverException),
      );
    } on Exception catch (e, st) {
      logError('$e', traceId: traceId, error: e, stackTrace: st);
      return AppResult.failure(
        AppException('$e', code: AppExceptionCode.internalException),
      );
    }
  }
}
