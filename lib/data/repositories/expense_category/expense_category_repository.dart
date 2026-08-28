import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/data/repositories/account/firestore_account.dart';
import 'package:journexa_app/data/repositories/expense_category/firestore_expense_category.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/expense_category.dart';
import 'package:journexa_app/domain/repositories/i_expense_category.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

/// Firestore implementation of [IExpenseCategoryRepository]
@LazySingleton(as: IExpenseCategoryRepository)
class FirestoreExpenseCategoryRepository
    with Loggable
    implements IExpenseCategoryRepository {
  /// Creates new [FirestoreExpenseCategoryRepository]
  FirestoreExpenseCategoryRepository({required this._db});

  final FirebaseFirestore _db;

  @override
  String get logTag => 'FirestoreExpenseCategoryRepository';

  @override
  Future<AppResult<Null>> save({
    required String userId,
    required ExpenseCategory category,
    required String traceId,
  }) async {
    try {
      maybeThrowException(this, Invocation.method(#save, null));
      logInfo(
        'Starts checking expense category name',
        traceId: traceId,
        extras: {'name': category.name},
      );
      final expenseCategoriesCol = _db.collection(
        'users/$userId/expenseCategories',
      );
      final expenseCategoriesQuery = expenseCategoriesCol.where(
        'name',
        isEqualTo: category.name,
      );
      final expenseCategoriesSnaps = await expenseCategoriesQuery.get();
      if (expenseCategoriesSnaps.docs.isNotEmpty) {
        logInfo('Name already exists', traceId: traceId);
        return const AppResult.failure(
          AppException(
            'Expense category name already exists',
            code: AppExceptionCode.categoryNameAlreadyExists,
          ),
        );
      }

      final expenseCategoryFirestore = FirestoreExpenseCategory.fromDomain(
        category,
      );
      final accountFirestore = FirestoreAccount.fromDomain(category.account);
      logInfo(
        'Name not yet exists. Starts batch writes expense category and account',
        traceId: traceId,
        extras: {
          'expenseCategory': expenseCategoryFirestore.toJson(),
          'account': accountFirestore.toJson(),
        },
      );
      final expenseCategoryDoc = _db.doc(
        'users/$userId/expenseCategories/${category.id}',
      );
      final accountDoc = _db.doc(
        'users/$userId/accounts/${category.account.code}',
      );
      final batch = _db.batch()
        ..set(expenseCategoryDoc, expenseCategoryFirestore.toJson())
        ..set(accountDoc, accountFirestore.toJson());
      await batch.commit();
      logInfo(
        'Successfully written expense category and account to database',
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
  Future<AppResult<List<ExpenseCategory>>> getAll({
    required String userId,
    required String traceId,
    String? query,
    bool? isDeleted,
  }) async {
    try {
      maybeThrowException(this, Invocation.method(#getAll, null));
      logInfo(
        'Start fetching categories',
        traceId: traceId,
        extras: {'query': query},
      );
      Query<Map<String, Object?>> categoriesQuery = _db.collection(
        'users/$userId/expenseCategories',
      );
      if (query != null) {
        categoriesQuery = categoriesQuery
            .where('nameLower', isGreaterThanOrEqualTo: query)
            .where('nameLower', isLessThanOrEqualTo: '$query~');
      }
      if (isDeleted != null) {
        categoriesQuery = categoriesQuery.where(
          'isDeleted',
          isEqualTo: isDeleted,
        );
      }
      final categoriesSnap = await categoriesQuery.get();
      logInfo(
        'categories fetched. Start fetch each category account',
        traceId: traceId,
      );
      final result = <ExpenseCategory>[];
      final parentAccount = SystemDefinedAccount.rootExpense;
      for (final doc in categoriesSnap.docs) {
        final categoryFirestore = FirestoreExpenseCategory.fromJson(doc.data());
        logInfo(
          'Fetch account for category ${categoryFirestore.name}',
          traceId: traceId,
          extras: {'category': categoryFirestore.toJson()},
        );
        final accountDoc = _db.doc(
          'users/$userId/accounts/${categoryFirestore.accountCode}',
        );
        final accountSnap = await accountDoc.get();
        if (!accountSnap.exists) {
          logWarning(
            'Account ${categoryFirestore.accountCode} not found',
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
          categoryFirestore.toDomain(
            accountFirestore.toDomain().copyWith(
              parent: parentAccount,
            ),
          ),
        );
      }
      logInfo(
        'Successfully fetched categories',
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
    required ExpenseCategory category,
    required String traceId,
  }) async {
    try {
      maybeThrowException(this, Invocation.method(#delete, null));
      final categoryFirestore = FirestoreExpenseCategory.fromDomain(category);
      final accountFirestore = FirestoreAccount.fromDomain(category.account);
      logInfo(
        'Starts deleting category',
        traceId: traceId,
        extras: {
          'category': categoryFirestore.toJson(),
          'account': accountFirestore.toJson(),
        },
      );

      final categoryRef = _db.doc(
        'users/$userId/expenseCategories/${category.id}',
      );
      final categorySnap = await categoryRef.get();
      final categoryExists = categorySnap.exists;
      final accountRef = _db.doc(
        'users/$userId/accounts/${category.account.code}',
      );
      final accountSnap = await accountRef.get();
      final accountExists = accountSnap.exists;
      final batch = _db.batch();
      if (categoryExists) {
        batch.set(
          categoryRef,
          categoryFirestore.copyWith(isDeleted: true).toJson(),
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
        'Successfully deleted category and account',
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
    required ExpenseCategory updatedCategory,
    required String traceId,
  }) async {
    try {
      maybeThrowException(this, Invocation.method(#update, null));
      final categoryFirestore = FirestoreExpenseCategory.fromDomain(
        updatedCategory,
      );
      final accountFirestore = FirestoreAccount.fromDomain(
        updatedCategory.account,
      );

      logInfo(
        'Starts updating category',
        traceId: traceId,
        extras: {
          'category': categoryFirestore.toJson(),
          'account': accountFirestore.toJson(),
        },
      );
      final batch = _db.batch();
      final categoryRef = _db.doc(
        'users/$userId/expenseCategories/${updatedCategory.id}',
      );
      batch.set(categoryRef, categoryFirestore.toJson());
      final accountRef = _db.doc(
        'users/$userId/accounts/${updatedCategory.account.code}',
      );
      batch.set(accountRef, accountFirestore.toJson());
      await batch.commit();
      logInfo(
        'Successfully updated category and account',
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
