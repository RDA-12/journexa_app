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

  @override
  Future<AppResult<Null>> save(
    String userId,
    Account account, {
    required String traceId,
  }) async {
    try {
      final dbAccount = FirestoreAccount.fromDomain(account);
      logInfo(
        'Start saving Account',
        traceId: traceId,
        extras: dbAccount.toJson(),
      );
      final path = 'users/$userId/accounts/${dbAccount.code}';
      final doc = _db.doc(path);

      logInfo(
        'Get firestore data',
        traceId: traceId,
        extras: {'path': path},
      );
      final snapshot = await doc.get();
      if (snapshot.exists) {
        logError(
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

      logInfo(
        'Checks name on accounts collection',
        traceId: traceId,
      );
      final rootAccountsColRef = _db.collection('users/$userId/accounts');
      final query = rootAccountsColRef.where('name', isEqualTo: dbAccount.name);
      final snap = await query.get();
      if (snap.docs.isNotEmpty) {
        logError(
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
      logInfo(
        'Name not found in accounts collection. Save the Account',
        traceId: traceId,
      );

      await doc.set(dbAccount.toJson());
      logInfo('Account saved', traceId: traceId);
      return const AppResult.success(null);
    } on FirebaseException catch (e) {
      logError('$e', traceId: traceId, error: e);
      return AppResult.failure(
        AppException('$e', code: AppExceptionCode.serverException),
      );
    } on Exception catch (e, st) {
      logError(e.toString(), traceId: traceId, error: e, stackTrace: st);
      return AppResult.failure(
        AppException(
          e.toString(),
          code: AppExceptionCode.internalException,
        ),
      );
    }
  }

  @override
  Future<AppResult<List<Account>>> getByParentCode({
    required String userId,
    required String parentCode,
    required String traceId,
    String? query,
  }) async {
    try {
      maybeThrowException(
        this,
        Invocation.method(#getByParentCode, null, {
          #userId: userId,
          #parentCode: parentCode,
        }),
      );
      logInfo('Starts parent account', traceId: traceId);
      final parentRef = _db.doc('users/$userId/accounts/$parentCode');
      final parentSnap = await parentRef.get();
      if (!parentSnap.exists) {
        logError(
          'Parent account $parentCode not found',
          traceId: traceId,
        );
        return AppResult.failure(
          AppException(
            'Parent account $parentCode not found',
            code: AppExceptionCode.accountNotFound,
          ),
        );
      }
      final parent = FirestoreAccount.fromJson(parentSnap.data()!).toDomain();
      final colRef = _db.collection('users/$userId/accounts');
      var colQuery = colRef
          .where('parentCode', isEqualTo: parentCode)
          .where('isDeleted', isEqualTo: false);
      if (query != null) {
        colQuery = colQuery
            .where(
              'nameLower',
              isGreaterThanOrEqualTo: query.toLowerCase(),
            )
            .where(
              'nameLower',
              isLessThanOrEqualTo: '${query.toLowerCase()}~',
            );
      }
      final snap = await colQuery.get();
      if (snap.docs.isEmpty) {
        logInfo('No children found', traceId: traceId);
        return const AppResult.success([]);
      }
      logInfo('Children found. Mapping to domain model', traceId: traceId);
      final accounts = snap.docs.map(
        (it) => FirestoreAccount.fromJson(
          it.data(),
        ).toDomain().copyWith(parent: parent),
      );
      logInfo(
        'Mapping succeeded. Get children by parentCode success',
        traceId: traceId,
      );
      return AppResult.success(accounts.toList());
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
  Future<AppResult<Null>> deleteByCode({
    required String userId,
    required String code,
    required String traceId,
  }) async {
    try {
      maybeThrowException(
        this,
        Invocation.method(#deleteByCode, null, {
          #userId: userId,
          #code: code,
        }),
      );
      logInfo('Start update account data to isDeleted: true', traceId: traceId);
      final doc = _db.doc('users/$userId/accounts/$code');
      final snap = await doc.get();
      if (!snap.exists) {
        logInfo('Account not found. Do nothing', traceId: traceId);
        return const AppResult.success(null);
      }
      logInfo('Account found. Set isDeleted: true', traceId: traceId);
      final account = FirestoreAccount.fromJson(snap.data()!);
      final updated = account.copyWith(isDeleted: true);
      await doc.set(updated.toJson());
      logInfo('Account updated', traceId: traceId);
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
  Future<AppResult<Account>> getByCode({
    required String userId,
    required String code,
    required String traceId,
  }) async {
    try {
      logInfo('Start get account by code', traceId: traceId);
      final doc = _db.doc('users/$userId/accounts/$code');
      final snap = await doc.get();
      if (!snap.exists) {
        logWarning('Account not found', traceId: traceId);
        return AppResult.failure(
          AppException(
            'Account $code not found',
            code: AppExceptionCode.accountNotFound,
          ),
        );
      }
      logInfo('Account found. Mapping to domain model', traceId: traceId);
      final account = FirestoreAccount.fromJson(snap.data()!).toDomain();
      logInfo(
        'Mapping succeeded. Get account by code success',
        traceId: traceId,
      );
      return AppResult.success(account);
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
    required Account updatedAccount,
    required String traceId,
  }) async {
    try {
      final firestoreAccount = FirestoreAccount.fromDomain(updatedAccount);
      logInfo(
        'Starts checking the account',
        traceId: traceId,
        extras: firestoreAccount.toJson(),
      );
      final doc = _db.doc('users/$userId/accounts/${updatedAccount.code}');
      final snap = await doc.get();
      if (!snap.exists) {
        logWarning('Account not found', traceId: traceId);
        return AppResult.failure(
          AppException(
            'Account ${updatedAccount.code} not found',
            code: AppExceptionCode.accountNotFound,
          ),
        );
      }

      logInfo(
        'Account found. Start checking updated name',
        traceId: traceId,
        extras: firestoreAccount.toJson(),
      );
      final query = _db
          .collection('users/$userId/accounts')
          .where('code', isNotEqualTo: updatedAccount.code)
          .where('name', isEqualTo: updatedAccount.name);
      final accountsSnap = await query.get();
      if (accountsSnap.docs.isNotEmpty) {
        logInfo(
          'Name already exists',
          traceId: traceId,
          extras: {
            'name': updatedAccount.name,
          },
        );
        return const AppResult.failure(
          AppException(
            'Account name already exists',
            code: AppExceptionCode.accountAlreadyExists,
          ),
        );
      }

      logInfo('Name not found. Start updating the account', traceId: traceId);
      await doc.update(firestoreAccount.toJson());
      logInfo(
        'Account updated. Update account success',
        traceId: traceId,
        extras: firestoreAccount.toJson(),
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
