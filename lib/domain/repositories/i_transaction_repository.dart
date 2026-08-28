import 'package:journexa_app/domain/entities/journal.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:journexa_app/shared/app_result.dart';

/// Repository to handles all [Transaction] operations
abstract interface class ITransactionRepository {
  /// Save [transaction] and [journalEntry] into [userId] database
  Future<AppResult<Null>> save({
    required String userId,
    required Transaction transaction,
    required JournalEntry journalEntry,
    required String traceId,
  });
}
