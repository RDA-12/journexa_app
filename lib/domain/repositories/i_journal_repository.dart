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
  ///
  /// [counterpartAccount] makes the balance returned only when that account
  /// exists.
  ///
  /// for example,
  /// ```Dart
  /// // entry1 => dr 20 to A. cr 20 to B
  /// // entry2 => dr 30 to A. cr 30 to C
  ///
  /// // when do
  /// final stream = watchAccountBalance({
  ///   account: A, counterpartAccount: C, traceId: 'trace'
  /// });
  ///
  /// final data = await stream.first;
  /// print(data); // 30
  /// ```
  ///
  /// The entry1 have B account as counterpart to A (the account that will be
  /// watched). So, that entry not included.
  ///
  /// Its useful for getting income to specific wallet or getting expense from
  /// specific wallet
  ///
  /// ```Dart
  /// final watchWalletAIncome = watchAccountBalance({
  ///   account: SystemDefinedAccount.incomeParent,
  ///   counterpart: walletA.account,
  ///   traceId: 'trace',
  /// })
  /// ```
  Stream<AppResult<Decimal>> watchAccountBalance({
    required Account account,
    required String traceId,
    Account? counterpartAccount,
    DateTime? from,
    DateTime? to,
  });
}
