import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/repositories/i_journal_repository.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';

part 'watch_total_mtd_income_balance.freezed.dart';

/// Params for [WatchTotalMTDIncomeBalanceUseCase]
@freezed
sealed class WatchTotalMTDIncomeBalanceParams
    with _$WatchTotalMTDIncomeBalanceParams {
  const factory WatchTotalMTDIncomeBalanceParams({
    required DateTime targetDate,
  }) = _WatchTotalMTDIncomeBalanceParams;
}

/// Use case to get total month to date (MTD) income balance
@lazySingleton
class WatchTotalMTDIncomeBalanceUseCase
    with Loggable
    implements StreamBaseUseCase<WatchTotalMTDIncomeBalanceParams, Decimal> {
  /// Creates new [WatchTotalMTDIncomeBalanceUseCase]
  WatchTotalMTDIncomeBalanceUseCase({
    required this._journalRepository,
  });

  @override
  String get logTag => 'WatchTotalMTDIncomeBalanceUseCase';

  final IJournalRepository _journalRepository;

  @override
  Stream<AppResult<Decimal>> execute(
    WatchTotalMTDIncomeBalanceParams params, {
    required String traceId,
  }) {
    final targetDate = params.targetDate;
    final startDate = DateTime(targetDate.year, targetDate.month);
    final toDate = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      23,
      59,
      59,
      999,
    );
    logInfo('Starts watch total income balance', traceId: traceId);
    return _journalRepository.watchAccountBalance(
      account: SystemDefinedAccount.incomeParent,
      from: startDate,
      to: toDate,
      traceId: traceId,
    );
  }
}
