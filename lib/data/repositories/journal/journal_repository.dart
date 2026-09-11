import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/data/database.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/repositories/i_journal_repository.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:rxdart/rxdart.dart';

/// Drift implementation of [IJournalRepository]
@LazySingleton(as: IJournalRepository)
class DriftJournalRepository with Loggable implements IJournalRepository {
  /// Creates new [DriftJournalRepository]
  DriftJournalRepository({required this._db});

  final AppLocalDatabase _db;

  @override
  String get logTag => 'DriftJournalRepository';

  @override
  Future<AppResult<Decimal>> getAccountBalance({
    required Account account,
    required String traceId,
  }) async {
    try {
      maybeThrowException(this, Invocation.method(#getAccountBalance, null));
      logInfo(
        'Starts get balance for account',
        traceId: traceId,
        extras: {
          'accountCode': account.code,
        },
      );
      final statement = _db.select(_db.journalEntryLineDB)
        ..where((tbl) => tbl.accountCode.equals(account.code));
      final lines = await statement.get();
      var totalDebit = Decimal.zero;
      var totalCredit = Decimal.zero;
      for (final line in lines) {
        totalDebit += line.debit;
        totalCredit += line.credit;
      }

      final Decimal balance;
      if (account.normalBalance == BalanceType.debit) {
        balance = totalDebit - totalCredit;
      } else {
        balance = totalCredit - totalDebit;
      }
      logInfo(
        'Get account balance finished',
        traceId: traceId,
      );
      return AppResult.success(balance);
    } on Exception catch (e, st) {
      logError('$e', traceId: traceId, error: e, stackTrace: st);
      return AppResult.failure(
        AppException('$e', code: AppExceptionCode.internalException),
      );
    }
  }

  @override
  Stream<AppResult<Map<String, Decimal>>> watchAccountBalances({
    required String traceId,
  }) {
    logInfo(
      'Starts watching current balance for all accounts',
      traceId: traceId,
    );
    final statement = _db.select(_db.journalEntryLineDB).join([
      innerJoin(
        _db.accountDB,
        _db.accountDB.code.equalsExp(_db.journalEntryLineDB.accountCode),
      ),
    ]);

    return statement
        .watch()
        .map((rows) {
          maybeThrowException(
            this,
            Invocation.method(#watchAccountBalances, null),
          );
          final accountDebits = <String, Decimal>{};
          final accountCredits = <String, Decimal>{};
          final accountTypes = <String, AccountType>{};

          for (final row in rows) {
            final line = row.readTable(_db.journalEntryLineDB);
            final account = row.readTable(_db.accountDB);
            final code = line.accountCode;
            accountDebits[code] =
                (accountDebits[code] ?? Decimal.zero) + line.debit;
            accountCredits[code] =
                (accountCredits[code] ?? Decimal.zero) + line.credit;
            accountTypes[code] ??= AccountType.fromKey(account.type);
          }

          final result = <String, Decimal>{};
          for (final code in accountTypes.keys) {
            final type = accountTypes[code]!;
            final debit = accountDebits[code] ?? Decimal.zero;
            final credit = accountCredits[code] ?? Decimal.zero;
            if (AccountType.debitNormalBalance.contains(type)) {
              result[code] = debit - credit;
            } else {
              result[code] = credit - debit;
            }
          }
          return AppResult.success(result);
        })
        .onErrorReturnWith((err, st) {
          logError('$err', traceId: traceId, error: err, stackTrace: st);
          return AppResult.failure(
            AppException('$err', code: AppExceptionCode.internalException),
          );
        });
  }
}
