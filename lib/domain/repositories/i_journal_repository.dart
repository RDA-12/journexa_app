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
  ///
  /// If [from] is provided, it will return balance from that date (inclusive).
  /// If [to] is provided, it will return balance up to that date (inclusive).
  ///
  /// If [from] and [to] not provided, it will return balance from
  /// start to now.
  Stream<AppResult<Map<String, Decimal>>> watchAccountBalances({
    required String traceId,
    DateTime? from,
    DateTime? to,
  });

  /// Watch balance of the [account]
  ///
  /// If [from] is provided, it will return balance from that date (inclusive).
  /// If [to] is provided, it will return balance up to that date (inclusive).
  ///
  /// If [from] and [to] not provided, it will return balance from
  /// start to now.
  Stream<AppResult<Decimal>> watchAccountBalance({
    required Account account,
    required String traceId,
    DateTime? from,
    DateTime? to,
  });
}
