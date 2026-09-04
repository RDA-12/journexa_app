import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/repositories/i_transaction_repository.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';

/// Use case to stream transactions for current user
@lazySingleton
class WatchTransactionsUseCase
    with Loggable
    implements StreamBaseUseCaseNoParams<List<Transaction>> {
  /// Creates new [WatchTransactionsUseCase]
  WatchTransactionsUseCase({
    required this._authRepository,
    required this._transactionRepository,
  });

  final IAuthRepository _authRepository;
  final ITransactionRepository _transactionRepository;

  @override
  String get logTag => 'WatchTransactionsUseCase';

  @override
  Stream<AppResult<List<Transaction>>> execute({
    required String traceId,
  }) async* {
    logInfo('Starts getting current user id', traceId: traceId);
    final currentUserResult = await _authRepository.getCurrentUserId(
      traceId: traceId,
    );
    final currentUserExc = currentUserResult.errorOrNull;
    if (currentUserExc != null) {
      logInfo('Failed to get current user id', traceId: traceId);
      yield AppResult.failure(currentUserExc);
      return;
    }

    final userId = currentUserResult.valueOrNull!;
    logInfo(
      'Current user id obtained. Starts watching transactions',
      traceId: traceId,
    );
    yield* _transactionRepository.watch(
      userId: userId,
      traceId: traceId,
    );
  }
}
