import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/journal.dart';
import 'package:journexa_app/shared/app_result.dart';

/// Repository that handles [JournalEntry] operations
abstract interface class IJournalRepository {
  /// Return map of account code and account balance
  Future<AppResult<Map<String, AccountBalance>>> getCurrentBalance({
    required String userId,
    required List<Account> accounts,
    required String traceId,
  });
}
