import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/repositories/i_journal_repository.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';

part 'watch_total_mtd_income.freezed.dart';

/// Params for [WatchTotalMTDIncomeUseCase]
@freezed
sealed class WatchTotalMTDIncomeParams with _$WatchTotalMTDIncomeParams {
  const factory({
    required DateTime targetDate,
    Wallet? wallet,
  }) = _WatchTotalMTDIncomeParams;
}

/// Use case to get total month to date (MTD) income balance
@lazySingleton
class WatchTotalMTDIncomeUseCase
    with Loggable
    implements StreamBaseUseCase<WatchTotalMTDIncomeParams, Decimal> {
  /// Creates new [WatchTotalMTDIncomeUseCase]
  new({
    required this._journalRepository,
  });

  @override
  String get logTag => 'WatchTotalMTDIncomeUseCase';

  final IJournalRepository _journalRepository;

  @override
  Stream<AppResult<Decimal>> execute(
    WatchTotalMTDIncomeParams params, {
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
      counterpartAccount: params.wallet?.account,
      from: startDate,
      to: toDate,
      traceId: traceId,
    );
  }
}
