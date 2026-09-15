import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/data/database.dart';
import 'package:journexa_app/data/repositories/account/account.dart';
import 'package:journexa_app/data/repositories/income_category/income_category.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/domain/repositories/i_income_category_repository.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:rxdart/rxdart.dart';

/// Drift implementation of [IIncomeCategoryRepository]
@LazySingleton(as: IIncomeCategoryRepository)
class DriftIncomeCategoryRepository
    with Loggable
    implements IIncomeCategoryRepository {
  /// Creates new [DriftIncomeCategoryRepository]
  new({required this._db});

  final AppLocalDatabase _db;

  @override
  String get logTag => 'DriftIncomeCategoryRepository';

  @override
  Future<AppResult<Null>> save({
    required IncomeCategory category,
    required String traceId,
  }) async {
    try {
      maybeThrowException(this, Invocation.method(#save, null));
      logInfo(
        'Starts transactions to writes income category and account',
        traceId: traceId,
        extras: {
          'incomeCategoryId': category.id,
          'accountCode': category.account.code,
        },
      );
      await _db.transaction(() async {
        await _db.into(_db.incomeCategoryDB).insert(category.toDB());
        await _db.into(_db.accountDB).insert(category.account.toDB());
      });
      logInfo(
        'Successfully written income category and account to database',
        traceId: traceId,
      );
      return const AppResult.success(null);
    } on SqliteException catch (e) {
      if (e.extendedResultCode == 2067) {
        logInfo('Name already exists', traceId: traceId);
        return const AppResult.failure(
          AppException(
            'Income category name already exists',
            code: AppExceptionCode.categoryNameAlreadyExists,
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
  Stream<AppResult<List<IncomeCategory>>> watch({
    required String traceId,
    String? query,
    bool? isDeleted,
  }) {
    logInfo(
      'Constructing streams for income categories and its accounts',
      traceId: traceId,
      extras: {'query': query},
    );
    final statement = _db.select(_db.incomeCategoryDB).join([
      leftOuterJoin(
        _db.accountDB,
        _db.incomeCategoryDB.accountCode.equalsExp(_db.accountDB.code),
      ),
    ]);
    if (query != null) {
      statement.where(_db.incomeCategoryDB.name.like('%$query%'));
    }
    if (isDeleted != null) {
      statement.where(_db.incomeCategoryDB.isDeleted.equals(isDeleted));
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
            final result = <IncomeCategory>[];
            for (final row in rows) {
              final incomeCategoryDB = row.readTable(_db.incomeCategoryDB);
              final accountDB = row.readTable(_db.accountDB);
              result.add(
                incomeCategoryDB.toDomain(
                  account: accountDB.toDomain(
                    parent: SystemDefinedAccount.incomeParent,
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
    required IncomeCategory category,
    required String traceId,
  }) async {
    try {
      maybeThrowException(this, Invocation.method(#delete, null));
      logInfo(
        'Starts deleting income category and its account',
        traceId: traceId,
        extras: {
          'categoryId': category.id,
          'accountCode': category.account.code,
        },
      );
      await _db.transaction(() async {
        final updateCategoryStatement = _db.update(
          _db.incomeCategoryDB,
        )..where((it) => it.id.equals(category.id));
        await updateCategoryStatement.write(
          const IncomeCategoryDBCompanion(isDeleted: Value(true)),
        );
        final updateAccountStatement = _db.update(
          _db.accountDB,
        )..where((it) => it.code.equals(category.account.code.value));
        await updateAccountStatement.write(
          const AccountDBCompanion(isDeleted: Value(true)),
        );
      });
      logInfo(
        'Successfully deleted category and account',
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
    required IncomeCategory updatedCategory,
    required String traceId,
  }) async {
    try {
      maybeThrowException(this, Invocation.method(#update, null));
      logInfo(
        'Starts updating category',
        traceId: traceId,
        extras: {
          'categoryId': updatedCategory.id,
          'accountCode': updatedCategory.account.code,
        },
      );
      await _db.transaction(() async {
        final updateCategoryStatement = _db.update(
          _db.incomeCategoryDB,
        );
        await updateCategoryStatement.replace(updatedCategory.toDB());
        final updateAccountStatement = _db.update(
          _db.accountDB,
        );
        await updateAccountStatement.replace(updatedCategory.account.toDB());
      });
      logInfo(
        'Successfully updated category and account',
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
