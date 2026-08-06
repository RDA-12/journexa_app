import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/data/repositories/account/firestore_account.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/repositories/i_account_repository.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';

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
}
