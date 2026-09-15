import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/data/database.dart';
import 'package:journexa_app/data/repositories/account/account.dart';
import 'package:journexa_app/data/repositories/expense_category/expense_category.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/expense_category.dart';
import 'package:journexa_app/domain/repositories/i_expense_category_repository.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:rxdart/rxdart.dart';

/// Drift implementation of [IExpenseCategoryRepository]
@LazySingleton(as: IExpenseCategoryRepository)
class DriftExpenseCategoryRepository
    with Loggable
    implements IExpenseCategoryRepository {
  /// Creates new [DriftExpenseCategoryRepository]
  new({required this._db});

  final AppLocalDatabase _db;

  @override
  String get logTag => 'DriftExpenseCategoryRepository';

  @override
  Future<AppResult<Null>> save({
    required ExpenseCategory category,
    required String traceId,
  }) async {
    try {
      maybeThrowException(this, Invocation.method(#save, null));
      logInfo(
        'Starts transactions to writes expense category and account',
        traceId: traceId,
        extras: {
          'expenseCategoryId': category.id,
          'accountCode': category.account.code,
        },
      );
      await _db.transaction(() async {
        await _db.into(_db.expenseCategoryDB).insert(category.toDB());
        await _db.into(_db.accountDB).insert(category.account.toDB());
      });
      logInfo(
        'Successfully written expense category and account to database',
        traceId: traceId,
      );
      return const AppResult.success(null);
    } on SqliteException catch (e) {
      if (e.extendedResultCode == 2067) {
        logInfo('Name already exists', traceId: traceId);
        return const AppResult.failure(
          AppException(
            'Expense category name already exists',
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
  Stream<AppResult<List<ExpenseCategory>>> watch({
    required String traceId,
    String? query,
    bool? isDeleted,
  }) {
    logInfo(
      'Constructing streams for expense categories and its accounts',
      traceId: traceId,
      extras: {'query': query},
    );
    final statement = _db.select(_db.expenseCategoryDB).join([
      leftOuterJoin(
        _db.accountDB,
        _db.expenseCategoryDB.accountCode.equalsExp(_db.accountDB.code),
      ),
    ]);
    if (query != null) {
      statement.where(_db.expenseCategoryDB.name.like('%$query%'));
    }
    if (isDeleted != null) {
      statement.where(_db.expenseCategoryDB.isDeleted.equals(isDeleted));
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
            final result = <ExpenseCategory>[];
            for (final row in rows) {
              final expenseCategoryDB = row.readTable(_db.expenseCategoryDB);
              final accountDB = row.readTable(_db.accountDB);
              result.add(
                expenseCategoryDB.toDomain(
                  account: accountDB.toDomain(
                    parent: SystemDefinedAccount.expenseParent,
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
    required ExpenseCategory category,
    required String traceId,
  }) async {
    try {
      maybeThrowException(this, Invocation.method(#delete, null));
      logInfo(
        'Starts deleting expense category and its account',
        traceId: traceId,
        extras: {
          'categoryId': category.id,
          'accountCode': category.account.code,
        },
      );
      await _db.transaction(() async {
        final updateCategoryStatement = _db.update(
          _db.expenseCategoryDB,
        )..where((it) => it.id.equals(category.id));
        await updateCategoryStatement.write(
          const ExpenseCategoryDBCompanion(isDeleted: Value(true)),
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
    required ExpenseCategory updatedCategory,
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
          _db.expenseCategoryDB,
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
