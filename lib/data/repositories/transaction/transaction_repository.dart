import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:injectable/injectable.dart';
import 'package:journexa_app/data/repositories/journal/firestore_journal.dart';
import 'package:journexa_app/data/repositories/transaction/firestore_transaction.dart';
import 'package:journexa_app/domain/entities/journal.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:journexa_app/domain/repositories/i_transaction_repository.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

/// Firestore implementation of [ITransactionRepository]
@LazySingleton(as: ITransactionRepository)
class FirestoreTransactionRepository
    with Loggable
    implements ITransactionRepository {
  /// Creates new [FirestoreTransactionRepository]
  FirestoreTransactionRepository({required this._db});

  final FirebaseFirestore _db;

  @override
  String get logTag => 'FirestoreTransactionRepository';

  @override
  Future<AppResult<Null>> save({
    required String userId,
    required Transaction transaction,
    required JournalEntry journalEntry,
    required String traceId,
  }) async {
    try {
      maybeThrowException(this, Invocation.method(#save, null));
      logInfo(
        'Creates firestore object for transaction, journal entry and its lints',
        traceId: traceId,
      );
      final firestoreTransaction = FirestoreTransaction.fromDomain(transaction);
      final firestoreJournalEntry = FirestoreJournalEntry.fromDomain(
        journalEntry,
      );
      final firestoreLines = journalEntry.lines
          .map(FirestoreJournalEntryLine.fromDomain)
          .toList();
      logInfo(
        'Objects created. Starts batch write',
        traceId: traceId,
        extras: {
          'transactionId': firestoreTransaction.id,
          'journalEntryId': firestoreJournalEntry.id,
          'lineCount': firestoreLines.length,
        },
      );
      final batch = _db.batch();
      final transactionRef = _db.doc(
        'users/$userId/transactions/${firestoreTransaction.id}',
      );
      batch.set(transactionRef, firestoreTransaction.toJson());
      final journalEntryRef = _db.doc(
        'users/$userId/journalEntries/${firestoreJournalEntry.id}',
      );
      batch.set(journalEntryRef, firestoreJournalEntry.toJson());
      for (var i = 0; i < firestoreLines.length; i++) {
        final line = firestoreLines[i];
        final lineColRef = _db.collection(
          'users/$userId/journalEntries/${firestoreJournalEntry.id}/lines',
        );
        batch.set(lineColRef.doc(), line.toJson());
      }
      logInfo('Batch write prepared. Executes.', traceId: traceId);
      await batch.commit();
      logInfo('Batch write completed successfully.', traceId: traceId);
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
