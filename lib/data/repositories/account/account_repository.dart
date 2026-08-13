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
class FirestoreAccountRepository implements IAccountRepository {
  /// Creates new [FirestoreAccountRepository]
  FirestoreAccountRepository({required this._db})
    : _logger = AppLogger('FirestoreAccountRepository');

  final FirebaseFirestore _db;
  final AppLogger _logger;

  @override
  Future<AppResult<Null>> ensureSaved(
    String userId, {
    required List<Account> accounts,
    required String traceId,
  }) async {
    try {
      _logger.info(
        'Start ensuring accounts saved',
        traceId: traceId,
      );
      for (final account in accounts) {
        _logger.info('Checks ${account.name}', traceId: traceId);
        final doc = _db.doc('users/$userId/accounts/${account.code}');
        final data = await doc.get();
        if (!data.exists) {
          _logger.info(
            '${account.name} doesnt exists. Save the default account',
            traceId: traceId,
          );
          await doc.set(FirestoreAccount.fromDomain(account).toJson());
        } else {
          _logger.info('${account.name} exists', traceId: traceId);
        }
      }
      return const AppResult.success(null);
    } on FirebaseException catch (e) {
      _logger.error(
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
      _logger.error(
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
      _logger.info(
        'Start get parentCode children count',
        traceId: traceId,
        extras: {'parentCode': parentCode},
      );
      final colRef = _db.collection('users/$userId/accounts');
      final query = colRef.where('parentCode', isEqualTo: parentCode).count();
      final snap = await query.get();
      final count = snap.count ?? 0;
      _logger.info(
        'Found $count children for parentCode $parentCode',
        traceId: traceId,
        extras: {'count': count},
      );
      return AppResult.success(count);
    } on FirebaseException catch (e) {
      _logger.error('$e', traceId: traceId, error: e);
      return AppResult.failure(
        AppException('$e', code: AppExceptionCode.serverException),
      );
    } on Exception catch (e, st) {
      _logger.error('$e', traceId: traceId, error: e, stackTrace: st);
      return AppResult.failure(
        AppException('$e', code: AppExceptionCode.internalException),
      );
    }
  }

  @override
  Future<AppResult<Null>> save(
    String userId,
    Account account, {
    required String traceId,
  }) async {
    try {
      final dbAccount = FirestoreAccount.fromDomain(account);
      _logger.info(
        'Start saving Account',
        traceId: traceId,
        extras: dbAccount.toJson(),
      );
      final path = 'users/$userId/accounts/${dbAccount.code}';
      final doc = _db.doc(path);

      _logger.info(
        'Get firestore data',
        traceId: traceId,
        extras: {'path': path},
      );
      final snapshot = await doc.get();
      if (snapshot.exists) {
        _logger.error(
          'Account with code ${account.code} already exists',
          traceId: traceId,
        );
        return AppResult.failure(
          AppException(
            'Account with code ${account.code} already exists',
            code: AppExceptionCode.accountAlreadyExists,
          ),
        );
      }

      _logger.info(
        'Checks name on accounts collection',
        traceId: traceId,
      );
      final rootAccountsColRef = _db.collection('users/$userId/accounts');
      final query = rootAccountsColRef.where('name', isEqualTo: dbAccount.name);
      final snap = await query.get();
      if (snap.docs.isNotEmpty) {
        _logger.error(
          'Account with name ${account.name} already exists',
          traceId: traceId,
        );
        return AppResult.failure(
          AppException(
            'Account with name ${account.name} already exists',
            code: AppExceptionCode.accountAlreadyExists,
          ),
        );
      }
      _logger.info(
        'Name not found in accounts collection. Save the Account',
        traceId: traceId,
      );

      await doc.set(dbAccount.toJson());
      _logger.info('Account saved', traceId: traceId);
      return const AppResult.success(null);
    } on FirebaseException catch (e) {
      _logger.error('$e', traceId: traceId, error: e);
      return AppResult.failure(
        AppException('$e', code: AppExceptionCode.serverException),
      );
    } on Exception catch (e, st) {
      _logger.error(e.toString(), traceId: traceId, error: e, stackTrace: st);
      return AppResult.failure(
        AppException(
          e.toString(),
          code: AppExceptionCode.internalException,
        ),
      );
    }
  }
}
