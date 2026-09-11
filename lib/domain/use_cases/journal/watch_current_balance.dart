import 'package:decimal/decimal.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/repositories/i_journal_repository.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';

/// Use case to watch account current balance changes
@lazySingleton
class WatchCurrentBalanceUseCase
    with Loggable
    implements StreamBaseUseCaseNoParams<Map<String, Decimal>> {
  /// Creates new [WatchCurrentBalanceUseCase]
  WatchCurrentBalanceUseCase({
    required this._journalRepository,
  });

  final IJournalRepository _journalRepository;

  @override
  String get logTag => 'WatchCurrentBalanceUseCase';

  @override
  Stream<AppResult<Map<String, Decimal>>> execute({
    required String traceId,
  }) async* {
    logInfo(
      'Starts watching current balance',
      traceId: traceId,
    );
    yield* _journalRepository.watchAccountBalances(
      traceId: traceId,
    );
  }
}
