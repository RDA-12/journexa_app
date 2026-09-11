import 'package:decimal/decimal.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/journal.dart';
import 'package:journexa_app/shared/app_result.dart';

/// Repository that handles [JournalEntry] operations
abstract interface class IJournalRepository {
  /// Return balance of the [account]
  Future<AppResult<Decimal>> getAccountBalance({
    required Account account,
    required String traceId,
  });

  /// Watch [Account] balances. Emits Map of account code and current balance
  Stream<AppResult<Map<String, Decimal>>> watchCurrentBalance({
    required String traceId,
  });
}
