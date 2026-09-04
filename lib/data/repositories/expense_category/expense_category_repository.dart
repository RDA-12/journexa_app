import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/data/repositories/account/firestore_account.dart';
import 'package:journexa_app/data/repositories/expense_category/firestore_expense_category.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/expense_category.dart';
import 'package:journexa_app/domain/repositories/i_expense_category_repository.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:rxdart/rxdart.dart';

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
  Stream<AppResult<List<ExpenseCategory>>> watch({
    required String userId,
    required String traceId,
    String? query,
    bool? isDeleted,
  }) {
    logInfo(
      'Constructing streams for expense categories and its accounts',
      traceId: traceId,
      extras: {'query': query},
    );
    Query<Map<String, Object?>> categoriesQuery = _db.collection(
      'users/$userId/expenseCategories',
    );
    Query<Map<String, Object?>> accountsQuery = _db.collection(
      'users/$userId/accounts',
    );
    if (query != null) {
      categoriesQuery = categoriesQuery
          .where('nameLower', isGreaterThanOrEqualTo: query)
          .where('nameLower', isLessThanOrEqualTo: '$query~');
      accountsQuery = accountsQuery
          .where('nameLower', isGreaterThanOrEqualTo: query)
          .where('nameLower', isLessThanOrEqualTo: '$query~');
    }
    if (isDeleted != null) {
      categoriesQuery = categoriesQuery.where(
        'isDeleted',
        isEqualTo: isDeleted,
      );
      accountsQuery = accountsQuery.where(
        'isDeleted',
        isEqualTo: isDeleted,
      );
    }
    final categoriesStream = categoriesQuery.snapshots();
    final accountsStream = accountsQuery.snapshots();
    logInfo(
      'Streams constructed. Return combined streams',
      traceId: traceId,
    );
    return CombineLatestStream.combine2(
      categoriesStream,
      accountsStream,
      (catSnap, accountSnap) {
        maybeThrowException(this, Invocation.method(#watch, null));
        logInfo(
          'Either category or account changed. '
          'Starts constructing expense categories',
          traceId: traceId,
        );
        final catDocs = catSnap.docs;
        final accountDocs = accountSnap.docs;
        final result = <ExpenseCategory>[];
        for (final catDoc in catDocs) {
          final firestoreCat = FirestoreExpenseCategory.fromJson(
            catDoc.data(),
          );
          final accountDoc = accountDocs.firstWhereOrNull((it) {
            return it.data()['code'] == firestoreCat.accountCode;
          });
          if (accountDoc == null) {
            logWarning(
              'Account for expense category ${firestoreCat.id} not found',
              traceId: traceId,
              extras: {
                'expenseCategoryId': firestoreCat.id,
              },
            );
            continue;
          }
          final firestoreAccount = FirestoreAccount.fromJson(
            accountDoc.data(),
          );
          final category = firestoreCat.toDomain(
            firestoreAccount.toDomain().copyWith(
              parent: SystemDefinedAccount.rootExpense,
            ),
          );
          result.add(category);
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
