import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/data/repositories/account/firestore_account.dart';
import 'package:journexa_app/data/repositories/income_category/firestore_income_category.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/domain/repositories/i_income_category.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:rxdart/rxdart.dart';

/// Firestore implementation of [IIncomeCategoryRepository]
@LazySingleton(as: IIncomeCategoryRepository)
class FirestoreIncomeCategoryRepository
    with Loggable
    implements IIncomeCategoryRepository {
  /// Creates new [FirestoreIncomeCategoryRepository]
  FirestoreIncomeCategoryRepository({required this._db});

  final FirebaseFirestore _db;

  @override
  String get logTag => 'FirestoreIncomeCategoryRepository';

  @override
  Future<AppResult<Null>> save({
    required String userId,
    required IncomeCategory category,
    required String traceId,
  }) async {
    try {
      maybeThrowException(this, Invocation.method(#save, null));
      logInfo(
        'Starts checking income category name',
        traceId: traceId,
        extras: {'name': category.name},
      );
      final incomeCategoriesCol = _db.collection(
        'users/$userId/incomeCategories',
      );
      final incomeCategoriesQuery = incomeCategoriesCol.where(
        'name',
        isEqualTo: category.name,
      );
      final incomeCategoriesSnaps = await incomeCategoriesQuery.get();
      if (incomeCategoriesSnaps.docs.isNotEmpty) {
        logInfo('Name already exists', traceId: traceId);
        return const AppResult.failure(
          AppException(
            'Income category name already exists',
            code: AppExceptionCode.categoryNameAlreadyExists,
          ),
        );
      }

      final incomeCategoryFirestore = FirestoreIncomeCategory.fromDomain(
        category,
      );
      final accountFirestore = FirestoreAccount.fromDomain(category.account);
      logInfo(
        'Name not yet exists. Starts batch writes income category and account',
        traceId: traceId,
        extras: {
          'incomeCategory': incomeCategoryFirestore.toJson(),
          'account': accountFirestore.toJson(),
        },
      );
      final incomeCategoryDoc = _db.doc(
        'users/$userId/incomeCategories/${category.id}',
      );
      final accountDoc = _db.doc(
        'users/$userId/accounts/${category.account.code}',
      );
      final batch = _db.batch()
        ..set(incomeCategoryDoc, incomeCategoryFirestore.toJson())
        ..set(accountDoc, accountFirestore.toJson());
      await batch.commit();
      logInfo(
        'Successfully written income category and account to database',
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
  Stream<AppResult<List<IncomeCategory>>> watch({
    required String userId,
    required String traceId,
    String? query,
    bool? isDeleted,
  }) {
    maybeThrowException(this, Invocation.method(#getAll, null));
    logInfo(
      'Constructing streams for income categories and its accounts',
      traceId: traceId,
      extras: {'query': query},
    );
    Query<Map<String, Object?>> categoriesQuery = _db.collection(
      'users/$userId/incomeCategories',
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
          'Starts constructing income categories',
          traceId: traceId,
        );
        final catDocs = catSnap.docs;
        final accountDocs = accountSnap.docs;
        final result = <IncomeCategory>[];
        for (final catDoc in catDocs) {
          final firestoreCat = FirestoreIncomeCategory.fromJson(
            catDoc.data(),
          );
          final accountDoc = accountDocs.firstWhereOrNull((it) {
            return it.data()['code'] == firestoreCat.accountCode;
          });
          if (accountDoc == null) {
            logWarning(
              'Account for income category ${firestoreCat.id} not found',
              traceId: traceId,
              extras: {
                'incomeCategoryId': firestoreCat.id,
              },
            );
            continue;
          }
          final firestoreAccount = FirestoreAccount.fromJson(
            accountDoc.data(),
          );
          final category = firestoreCat.toDomain(
            firestoreAccount.toDomain().copyWith(
              parent: SystemDefinedAccount.rootRevenue,
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
    required IncomeCategory category,
    required String traceId,
  }) async {
    try {
      maybeThrowException(this, Invocation.method(#delete, null));
      final categoryFirestore = FirestoreIncomeCategory.fromDomain(category);
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
        'users/$userId/incomeCategories/${category.id}',
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
    required IncomeCategory updatedCategory,
    required String traceId,
  }) async {
    try {
      maybeThrowException(this, Invocation.method(#update, null));
      final categoryFirestore = FirestoreIncomeCategory.fromDomain(
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
        'users/$userId/incomeCategories/${updatedCategory.id}',
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
