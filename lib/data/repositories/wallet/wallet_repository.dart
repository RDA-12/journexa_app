import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/data/repositories/account/account.dart';
import 'package:journexa_app/data/repositories/wallet/firestore_wallet.dart';
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
}
