import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/data/repositories/account/firestore_account.dart';
import 'package:journexa_app/data/repositories/income_category/firestore_income_category.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/domain/repositories/i_income_category.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

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
}
