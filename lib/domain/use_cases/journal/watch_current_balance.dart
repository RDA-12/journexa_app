import 'package:decimal/decimal.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
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
    required this._authRepository,
    required this._journalRepository,
  });

  final IAuthRepository _authRepository;
  final IJournalRepository _journalRepository;

  @override
  String get logTag => 'WatchCurrentBalanceUseCase';

  @override
  Stream<AppResult<Map<String, Decimal>>> execute({
    required String traceId,
  }) async* {
    logInfo('Start getting current user id', traceId: traceId);
    final currentUserIdRes = await _authRepository.getCurrentUserId(
      traceId: traceId,
    );
    final currentUserIdExc = currentUserIdRes.errorOrNull;
    if (currentUserIdExc != null) {
      logInfo('Failed to get current user id', traceId: traceId);
      yield AppResult.failure(currentUserIdExc);
      return;
    }

    logInfo(
      'Current user id obtained. Yield current balance stream',
      traceId: traceId,
    );
    final userId = currentUserIdRes.valueOrNull!;
    yield* _journalRepository.watchCurrentBalance(
      userId: userId,
      traceId: traceId,
    );
  }
}
