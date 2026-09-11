import 'package:journexa_app/domain/entities/journal.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:journexa_app/shared/app_result.dart';

/// Repository to handles all [Transaction] operations
abstract interface class ITransactionRepository {
  /// Save [transaction] and [journalEntry] into database
  Future<AppResult<Null>> save({
    required Transaction transaction,
    required JournalEntry journalEntry,
    required String traceId,
  });

  /// Watch all [Transaction]'s in database
  Stream<AppResult<List<Transaction>>> watch({
    required String traceId,
  });
}
