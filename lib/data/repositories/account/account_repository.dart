import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/data/repositories/account/firestore_account.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/repositories/i_account_repository.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

/// Firestre implementation of [IAccountRepository]
@LazySingleton(as: IAccountRepository)
class FirestoreAccountRepository with Loggable implements IAccountRepository {
  /// Creates new [FirestoreAccountRepository]
  FirestoreAccountRepository({required this._db});

  @override
  String get logTag => 'FirestoreAccountRepository';

  final FirebaseFirestore _db;

  @override
  Future<AppResult<Null>> ensureSaved(
    String userId, {
    required List<Account> accounts,
    required String traceId,
  }) async {
    try {
      logInfo(
        'Start ensuring accounts saved',
        traceId: traceId,
      );
      for (final account in accounts) {
        logInfo('Checks ${account.name}', traceId: traceId);
        final doc = _db.doc('users/$userId/accounts/${account.code}');
        final data = await doc.get();
        if (!data.exists) {
          logInfo(
            '${account.name} doesnt exists. Save the default account',
            traceId: traceId,
          );
          await doc.set(FirestoreAccount.fromDomain(account).toJson());
        } else {
          logInfo('${account.name} exists', traceId: traceId);
        }
      }
      return const AppResult.success(null);
    } on FirebaseException catch (e) {
      logError(
        'FirebaseException: [${e.code}] ${e.message}',
        traceId: traceId,
        error: e,
      );
      return AppResult.failure(
        AppException(
          e.message ?? e.code,
          code: AppExceptionCode.serverException,
        ),
      );
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
    required String userId,
    required String parentCode,
    required String traceId,
  }) async {
    try {
      // Uses internal expections_mocks
      // since default exception from FakeFiresbaseFirestore
      // didnt support AggregateQuery's get() method.
      maybeThrowException(
        this,
        Invocation.method(#getChildrenCountByParentCode, null, {
          #userId: userId,
          #parentCode: parentCode,
        }),
      );
      logInfo(
        'Start get parentCode children count',
        traceId: traceId,
        extras: {'parentCode': parentCode},
      );
      final colRef = _db.collection('users/$userId/accounts');
      final query = colRef.where('parentCode', isEqualTo: parentCode).count();
      final snap = await query.get();
      final count = snap.count ?? 0;
      logInfo(
        'Found $count children for parentCode $parentCode',
        traceId: traceId,
        extras: {'count': count},
      );
      return AppResult.success(count);
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
