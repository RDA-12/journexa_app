import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/data/database.dart';
import 'package:journexa_app/data/repositories/account/account_db.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/repositories/i_account_repository.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

/// Drift implementation of [IAccountRepository]
@LazySingleton(as: IAccountRepository)
class DriftAccountRepository with Loggable implements IAccountRepository {
  /// Creates new [DriftAccountRepository]
  new({required this._db});

  @override
  String get logTag => 'DriftAccountRepository';

  final AppLocalDatabase _db;

  @override
  Future<AppResult<Null>> ensureSaved({
    required List<Account> accounts,
    required String traceId,
  }) async {
    try {
      maybeThrowException(this, Invocation.method(#ensureSaved, null));
      logInfo(
        'Start ensuring accounts saved',
        traceId: traceId,
      );
      for (final account in accounts) {
        logInfo('Checks ${account.name}', traceId: traceId);
        final statement = _db.accountDB.count(
          where: (it) => it.code.equals(account.code.value),
        );
        final count = await statement.getSingle();
        if (count == 0) {
          logInfo(
            '${account.name} doesnt exists. Save the default account',
            traceId: traceId,
          );
          await _db.into(_db.accountDB).insert(account.toDB());
        } else {
          logInfo('${account.name} exists', traceId: traceId);
        }
      }
      return const AppResult.success(null);
    } on Exception catch (e, st) {
      logError(
        'Exception: $e',
        traceId: traceId,
        error: e,
        stackTrace: st,
      );
      return AppResult.failure(
        AppException(
          e.toString(),
          code: AppExceptionCode.internalException,
        ),
      );
    }
  }

  @override
  Future<AppResult<int>> getChildrenCountByParentCode({
    required String parentCode,
    required String traceId,
  }) async {
    try {
      maybeThrowException(
        this,
        Invocation.method(#getChildrenCountByParentCode, null),
      );
      logInfo(
        'Start get parentCode children count',
        traceId: traceId,
        extras: {'parentCode': parentCode},
      );
      final statement = _db.accountDB.count(
        where: (it) => it.parentCode.equals(parentCode),
      );
      final count = await statement.getSingle();
      logInfo(
        'Found $count children for parentCode $parentCode',
        traceId: traceId,
        extras: {'count': count},
      );
      return AppResult.success(count);
    } on Exception catch (e, st) {
      logError('$e', traceId: traceId, error: e, stackTrace: st);
      return AppResult.failure(
        AppException('$e', code: AppExceptionCode.internalException),
      );
    }
  }
}
