import 'package:cloud_firestore/cloud_firestore.dart';
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
  Future<AppResult<List<Wallet>>> getAll({
    required String userId,
    required String traceId,
    String? query,
  }) async {
    try {
      maybeThrowException(this, Invocation.method(#getAll, null));
      logInfo(
        'Start fetching Wallets',
        traceId: traceId,
        extras: {'query': query},
      );
      Query<Map<String, Object?>> walletsQuery = _db.collection(
        'users/$userId/wallets',
      );
      if (query != null) {
        walletsQuery = walletsQuery
            .where('nameLower', isGreaterThanOrEqualTo: query)
            .where('nameLower', isLessThanOrEqualTo: '$query~');
      }
      final walletsSnap = await walletsQuery.get();
      logInfo(
        'Wallets fetched. Start fetch each Wallet Account',
        traceId: traceId,
      );
      final result = <Wallet>[];
      final parentAccount = kSystemDefinedAccounts.firstWhere(
        (it) => it.code == '10.0000',
      );
      for (final doc in walletsSnap.docs) {
        final walletFirestore = FirestoreWallet.fromJson(doc.data());
        logInfo(
          'Fetch account for wallet ${walletFirestore.name}',
          traceId: traceId,
          extras: {'wallet': walletFirestore.toJson()},
        );
        final accountDoc = _db.doc(
          'users/$userId/accounts/${walletFirestore.accountCode}',
        );
        final accountSnap = await accountDoc.get();
        if (!accountSnap.exists) {
          logWarning(
            'Account ${walletFirestore.accountCode} not found',
            traceId: traceId,
          );
          continue;
        }
        final accountFirestore = FirestoreAccount.fromJson(accountSnap.data()!);
        logInfo(
          'Account found',
          traceId: traceId,
          extras: accountFirestore.toJson(),
        );
        result.add(
          walletFirestore.toDomain(
            accountFirestore.toDomain().copyWith(
              parent: parentAccount,
            ),
          ),
        );
      }
      logInfo(
        'Successfully fetched wallets',
        traceId: traceId,
        extras: {'count': result.length},
      );
      return AppResult.success(result);
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

      final batch = _db.batch();
      final walletRef = _db.doc('users/$userId/wallets/${wallet.id}');
      batch.delete(walletRef);
      final accountRef = _db.doc(
        'users/$userId/accounts/${wallet.account.code}',
      );
      batch.delete(accountRef);
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
  }) {
    // TODO: implement update
    throw UnimplementedError();
  }
}
