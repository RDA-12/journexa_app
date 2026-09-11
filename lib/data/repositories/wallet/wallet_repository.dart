import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/data/database.dart';
import 'package:journexa_app/data/repositories/account/account.dart';
import 'package:journexa_app/data/repositories/wallet/wallet.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/repositories/i_wallet_respository.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:rxdart/rxdart.dart';

/// Drift implementation of [IWalletRepository]
@LazySingleton(as: IWalletRepository)
class DriftWalletRepository with Loggable implements IWalletRepository {
  /// Creates new [DriftWalletRepository]
  DriftWalletRepository({required this._db});

  final AppLocalDatabase _db;

  @override
  String get logTag => 'DriftWalletRepository';

  @override
  Future<AppResult<Null>> save({
    required Wallet wallet,
    required String traceId,
  }) async {
    try {
      maybeThrowException(this, Invocation.method(#save, null));
      logInfo(
        'Starts transactions to writes wallet and account',
        traceId: traceId,
        extras: {
          'walletId': wallet.id,
          'accountCode': wallet.account.code,
        },
      );
      await _db.transaction(() async {
        await _db.into(_db.walletDB).insert(wallet.toDB());
        await _db.into(_db.accountDB).insert(wallet.account.toDB());
      });
      logInfo(
        'Successfully written wallet and account to database',
        traceId: traceId,
      );
      return const AppResult.success(null);
    } on SqliteException catch (e) {
      if (e.extendedResultCode == 2067) {
        logInfo('Name already exists', traceId: traceId);
        return const AppResult.failure(
          AppException(
            'Wallet name already exists',
            code: AppExceptionCode.walletNameAlreadyExists,
          ),
        );
      }
      logError('$e', traceId: traceId, error: e);
      return AppResult.failure(
        AppException('$e', code: AppExceptionCode.internalException),
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
    required String traceId,
    String? query,
    bool? isDeleted,
  }) {
    logInfo(
      'Constructing streams for wallets and its accounts',
      traceId: traceId,
      extras: {'query': query},
    );
    final statement = _db.select(_db.walletDB).join([
      leftOuterJoin(
        _db.accountDB,
        _db.walletDB.accountCode.equalsExp(_db.accountDB.code),
      ),
    ]);
    if (query != null) {
      statement.where(_db.walletDB.name.like('%$query%'));
    }
    if (isDeleted != null) {
      statement.where(_db.walletDB.isDeleted.equals(isDeleted));
    }
    final stream = statement.watch();
    logInfo(
      'Streams constructed. Return mapped streams',
      traceId: traceId,
    );
    return stream
        .map(
          (rows) {
            maybeThrowException(this, Invocation.method(#watch, null));
            final result = <Wallet>[];
            for (final row in rows) {
              final walletDB = row.readTable(_db.walletDB);
              final accountDB = row.readTable(_db.accountDB);
              result.add(
                walletDB.toDomain(
                  account: accountDB.toDomain(
                    parent: SystemDefinedAccount.rootAsset,
                  ),
                ),
              );
            }
            return AppResult.success(result);
          },
        )
        .onErrorReturnWith((err, st) {
          logError('$err', traceId: traceId, error: err, stackTrace: st);
          return AppResult.failure(
            AppException('$err', code: AppExceptionCode.internalException),
          );
        });
  }

  @override
  Future<AppResult<Null>> delete({
    required Wallet wallet,
    required String traceId,
  }) async {
    try {
      maybeThrowException(this, Invocation.method(#delete, null));
      logInfo(
        'Starts deleting wallet and its account',
        traceId: traceId,
        extras: {
          'walletId': wallet.id,
          'accountCode': wallet.account.code,
        },
      );
      await _db.transaction(() async {
        final updateWalletStatement = _db.update(
          _db.walletDB,
        )..where((it) => it.id.equals(wallet.id));
        await updateWalletStatement.write(
          const WalletDBCompanion(isDeleted: Value(true)),
        );
        final updateAccountStatement = _db.update(
          _db.accountDB,
        )..where((it) => it.code.equals(wallet.account.code));
        await updateAccountStatement.write(
          const AccountDBCompanion(isDeleted: Value(true)),
        );
      });
      logInfo(
        'Successfully deleted wallet and account',
        traceId: traceId,
      );
      return const AppResult.success(null);
    } on Exception catch (e, st) {
      logError('$e', traceId: traceId, error: e, stackTrace: st);
      return AppResult.failure(
        AppException('$e', code: AppExceptionCode.internalException),
      );
    }
  }

  @override
  Future<AppResult<Null>> update({
    required Wallet updatedWallet,
    required String traceId,
  }) async {
    try {
      maybeThrowException(this, Invocation.method(#update, null));
      logInfo(
        'Starts updating wallet',
        traceId: traceId,
        extras: {
          'walletId': updatedWallet.id,
          'accountCode': updatedWallet.account.code,
        },
      );
      await _db.transaction(() async {
        final updateWalletStatement = _db.update(
          _db.walletDB,
        );
        await updateWalletStatement.replace(updatedWallet.toDB());
        final updateAccountStatement = _db.update(
          _db.accountDB,
        );
        await updateAccountStatement.replace(updatedWallet.account.toDB());
      });
      logInfo(
        'Successfully updated wallet and account',
        traceId: traceId,
      );
      return const AppResult.success(null);
    } on Exception catch (e, st) {
      logError('$e', traceId: traceId, error: e, stackTrace: st);
      return AppResult.failure(
        AppException('$e', code: AppExceptionCode.internalException),
      );
    }
  }
}
