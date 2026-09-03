import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/repositories/i_transaction_repository.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';

/// Use case to get all [Transaction] data
/// for current user
@lazySingleton
class GetAllTransactionsUseCase
    with Loggable
    implements FutureBaseUseCaseNoParams<List<Transaction>> {
  /// Creates new [GetAllTransactionsUseCase]
  GetAllTransactionsUseCase({
    required this._authRepository,
    required this._transactionRepository,
  });

  final IAuthRepository _authRepository;
  final ITransactionRepository _transactionRepository;

  @override
  String get logTag => 'GetAllTransactionsUseCase';

  @override
  Future<AppResult<List<Transaction>>> execute({
    required String traceId,
  }) async {
    logInfo('Starts getting current user Id', traceId: traceId);
    final currentUserResult = await _authRepository.getCurrentUserId(
      traceId: traceId,
    );
    final currentUserExc = currentUserResult.errorOrNull;
    if (currentUserExc != null) {
      logInfo('Failed to get current user id', traceId: traceId);
      return AppResult.failure(currentUserExc);
    }

    final userId = currentUserResult.valueOrNull!;
    logInfo(
      'Current user id obtained. Starts getting all transactions',
      traceId: traceId,
    );
    final allTransactionsResult = await _transactionRepository.getAll(
      userId: userId,
      traceId: traceId,
    );
    final allTransactionsExc = allTransactionsResult.errorOrNull;
    if (allTransactionsExc != null) {
      logInfo('Failed to get all transactions', traceId: traceId);
      return AppResult.failure(allTransactionsExc);
    }
    logInfo('All transactions obtained successfully', traceId: traceId);
    return allTransactionsResult;
  }
}
