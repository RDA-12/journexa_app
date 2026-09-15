import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/data/database.dart';
import 'package:journexa_app/data/repositories/journal/journal.dart';
import 'package:journexa_app/data/repositories/transaction/transaction.dart';
import 'package:journexa_app/domain/entities/journal.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/repositories/i_transaction_repository.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:rxdart/rxdart.dart';

/// Drift implementation of [ITransactionRepository]
@LazySingleton(as: ITransactionRepository)
class DriftTransactionRepository
    with Loggable
    implements ITransactionRepository {
  /// Creates new [DriftTransactionRepository]
  new({required this._db});

  final AppLocalDatabase _db;

  @override
  String get logTag => 'DriftTransactionRepository';

  @override
  Future<AppResult<Null>> save({
    required Transaction transaction,
    required JournalEntry journalEntry,
    required String traceId,
  }) async {
    try {
      maybeThrowException(this, Invocation.method(#save, null));
      logInfo(
        'Starts transaction to write transaction, journal entry, and its lines',
        traceId: traceId,
        extras: {
          'transactionId': transaction.id,
          'journalEntryId': journalEntry.id,
          'lineCount': journalEntry.lines.length,
        },
      );
      await _db.transaction(() async {
        await _db.into(_db.transactionDB).insert(transaction.toDB());
        await _db.into(_db.journalEntryDB).insert(journalEntry.toDB());
        for (var i = 0; i < journalEntry.lines.length; i++) {
          final line = journalEntry.lines[i];
          await _db
              .into(_db.journalEntryLineDB)
              .insert(
                line.toDB(
                  id: '${journalEntry.id}-$i',
                  journalId: journalEntry.id,
                ),
              );
        }
      });
      logInfo(
        'Successfully written transaction, journal entry, '
        'and lines to database',
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
  Stream<AppResult<List<Transaction>>> watch({
    required String traceId,
    Wallet? wallet,
    int? limit,
  }) {
    final statement = _db.select(_db.transactionDB);
    if (wallet != null) {
      logInfo(
        'wallet filter provided. Filter stream by wallet',
        traceId: traceId,
      );
      statement.where(
        (tbl) => Expression.or([
          tbl.walletId.equals(wallet.id),
          tbl.sourceWalletId.equals(wallet.id),
          tbl.destinationWalletId.equals(wallet.id),
        ]),
      );
    }
    statement.orderBy([(tbl) => OrderingTerm.desc(tbl.date)]);
    if (limit != null) {
      logInfo(
        'limit provided. Filter stream by limit',
        traceId: traceId,
        extras: {'limit': limit},
      );
      statement.limit(limit);
    }
    logInfo(
      'Starts watching transactions',
      traceId: traceId,
    );
    final stream = statement.watch();
    return stream
        .map(
          (rows) {
            maybeThrowException(this, Invocation.method(#watch, null));
            logInfo(
              'Transactions rows obtained. Starts mapping',
              traceId: traceId,
            );
            final result = rows.map((row) => row.toDomain()).toList();
            logInfo(
              'Mapping completed. Returns results',
              traceId: traceId,
              extras: {'count': result.length},
            );
            return AppResult.success(result);
          },
        )
        .onErrorReturnWith((e, st) {
          logError('$e', traceId: traceId, error: e, stackTrace: st);
          return AppResult.failure(
            AppException('$e', code: AppExceptionCode.internalException),
          );
        });
  }
}
