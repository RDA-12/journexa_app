import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/entities/journal.dart';
import 'package:journexa_app/domain/repositories/i_account_repository.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/repositories/i_journal_repository.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';

part 'get_all_wallets.freezed.dart';

/// Params for [GetAllWalletsUseCase]
@freezed
sealed class GetAllWalletsParams with _$GetAllWalletsParams {
  const factory GetAllWalletsParams({
    String? query,
  }) = _GetAllWalletsParams;
}

/// Use case to get all Wallet Accounts saved on
/// current user database
@lazySingleton
class GetAllWalletsUseCase
    with Loggable
    implements FutureBaseUseCase<GetAllWalletsParams, List<AccountBalance>> {
  /// Creates new [GetAllWalletsUseCase]
  GetAllWalletsUseCase({
    required this._accountRepository,
    required this._authRepository,
    required this._journalRepository,
  });

  @override
  String get logTag => 'GetAllWalletUseCase';

  final IAuthRepository _authRepository;
  final IAccountRepository _accountRepository;
  final IJournalRepository _journalRepository;

  /// Execute getting all wallet Account from current user
  @override
  Future<AppResult<List<AccountBalance>>> execute(
    GetAllWalletsParams params, {
    required String traceId,
  }) async {
    logInfo('Starts getting current user id ', traceId: traceId);
    final currentUserIdResult = await _authRepository.getCurrentUserId(
      traceId: traceId,
    );
    final currentUserIdExc = currentUserIdResult.errorOrNull;
    if (currentUserIdExc != null) {
      logInfo('Failed to get current user id', traceId: traceId);
      return AppResult.failure(currentUserIdExc);
    }

    final userId = currentUserIdResult.valueOrNull!;
    logInfo(
      'Got current user id. Starts getting wallet accounts',
      traceId: traceId,
    );
    const parentCode = '10.0000';
    final accountsResult = await _accountRepository.getByParentCode(
      userId: userId,
      parentCode: parentCode,
      query: params.query,
      traceId: traceId,
    );
    final accountsExc = accountsResult.errorOrNull;
    if (accountsExc != null) {
      logInfo('Failed to get wallet accounts', traceId: traceId);
      return AppResult.failure(accountsExc);
    }

    final accounts = accountsResult.valueOrNull!;
    logInfo(
      'Got ${accounts.length} wallet accounts. Starts getting accounts balance',
      traceId: traceId,
    );
    final currentBalanceResult = await _journalRepository.getCurrentBalance(
      userId: userId,
      accounts: accounts,
      traceId: traceId,
    );
    final currentBalanceExc = currentBalanceResult.errorOrNull;
    if (currentBalanceExc != null) {
      logInfo('Failed to get accounts balance', traceId: traceId);
      return AppResult.failure(currentBalanceExc);
    }

    final balanceMap = currentBalanceResult.valueOrNull!;
    logInfo(
      'Got ${balanceMap.length} accounts balance. '
      'Converts Map to List',
      traceId: traceId,
    );
    final accountBalances = balanceMap.values.toList();
    return AppResult.success(accountBalances);
  }
}
