import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/repositories/i_journal_repository.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';

part 'watch_total_mtd_expense.freezed.dart';

/// Params for [WatchTotalMTDExpenseUseCase]
@freezed
sealed class WatchTotalMTDExpenseParams with _$WatchTotalMTDExpenseParams {
  const factory({
    required DateTime targetDate,
    Wallet? wallet,
  }) = _WatchTotalMTDExpenseParams;
}

/// Use case to get total month to date (MTD) expense balance
@lazySingleton
class WatchTotalMTDExpenseUseCase
    with Loggable
    implements StreamBaseUseCase<WatchTotalMTDExpenseParams, Decimal> {
  /// Creates new [WatchTotalMTDExpenseUseCase]
  new({
    required this._journalRepository,
  });

  @override
  String get logTag => 'WatchTotalMTDExpenseUseCase';

  final IJournalRepository _journalRepository;

  @override
  Stream<AppResult<Decimal>> execute(
    WatchTotalMTDExpenseParams params, {
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
    logInfo('Starts watch total expense balance', traceId: traceId);
    return _journalRepository.watchAccountBalance(
      account: SystemDefinedAccount.expenseParent,
      counterpartAccount: params.wallet?.account,
      from: startDate,
      to: toDate,
      traceId: traceId,
    );
  }
}
