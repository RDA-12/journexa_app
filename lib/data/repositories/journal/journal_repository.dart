import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decimal/decimal.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/data/repositories/journal/firestore_journal.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/journal.dart';
import 'package:journexa_app/domain/repositories/i_journal_repository.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:rxdart/rxdart.dart';

/// Firestore implementation of [IJournalRepository]
@LazySingleton(as: IJournalRepository)
class FirestoreJournalRepository with Loggable implements IJournalRepository {
  /// Creates new [FirestoreJournalRepository]
  FirestoreJournalRepository({required this._db});

  @override
  String get logTag => 'FirestoreJournalRepository';

  final FirebaseFirestore _db;

  @override
  Future<AppResult<Map<String, AccountBalance>>> getCurrentBalance({
    required String userId,
    required List<Account> accounts,
    required String traceId,
  }) async {
    try {
      maybeThrowException(this, Invocation.method(#getCurrentBalance, null));
      logInfo('Starts get current balance for accounts', traceId: traceId);
      final result = <String, AccountBalance>{};
      for (final account in accounts) {
        logInfo('Get balance for account ${account.name}', traceId: traceId);
        final doc = _db.doc('users/$userId/account_balance/${account.code}');
        final snap = await doc.get();
        if (!snap.exists) {
          logInfo(
            '${account.name} balance not exists. Return zero balance',
            traceId: traceId,
          );
          result[account.code] = AccountBalance(
            account: account,
            balance: Decimal.zero,
          );
        } else {
          logInfo('${account.name} balance exists', traceId: traceId);
          final data = FirestoreAccountBalance.fromJson(snap.data()!);
          result[account.code] = AccountBalance(
            account: account,
            balance: data.balance,
          );
        }
      }
      logInfo(
        'Get current balance for all accounts finished',
        traceId: traceId,
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
  Stream<AppResult<Map<String, Decimal>>> watchCurrentBalance({
    required String userId,
    required String traceId,
  }) {
    logInfo(
      'Starts watching current balance for all accounts',
      traceId: traceId,
    );
    return _db
        .collection('users/$userId/account_balance')
        .snapshots()
        .map((snap) {
      maybeThrowException(this, Invocation.method(#watchCurrentBalance, null));
      final result = <String, Decimal>{};
      for (final doc in snap.docs) {
        final data = FirestoreAccountBalance.fromJson(doc.data());
        result[data.code] = data.balance;
      }
      return AppResult.success(result);
    }).onErrorReturnWith((err, st) {
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
}
