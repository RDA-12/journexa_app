import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/repositories/i_journal_repository.dart';
import 'package:journexa_app/domain/repositories/i_wallet_respository.dart';
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

/// Use case to get all Wallets saved on
/// current user database
@lazySingleton
class GetAllWalletsUseCase
    with Loggable
    implements FutureBaseUseCase<GetAllWalletsParams, List<WalletWithBalance>> {
  /// Creates new [GetAllWalletsUseCase]
  GetAllWalletsUseCase({
    required this._walletRepository,
    required this._authRepository,
    required this._journalRepository,
  });

  @override
  String get logTag => 'GetAllWalletUseCase';

  final IAuthRepository _authRepository;
  final IWalletRepository _walletRepository;
  final IJournalRepository _journalRepository;

  /// Execute getting all wallet from current user
  @override
  Future<AppResult<List<WalletWithBalance>>> execute(
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
      'Got current user id. Starts getting wallets',
      traceId: traceId,
    );
    final walletsResult = await _walletRepository.getAll(
      userId: userId,
      query: params.query,
      isDeleted: false,
      traceId: traceId,
    );
    final accountsExc = walletsResult.errorOrNull;
    if (accountsExc != null) {
      logInfo('Failed to get wallets', traceId: traceId);
      return AppResult.failure(accountsExc);
    }

    final wallets = walletsResult.valueOrNull!;
    final accounts = wallets.map((it) => it.account).toList();
    logInfo(
      'Got ${wallets.length} wallets. Starts getting accounts balance',
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
      'Merge it with wallets to creates WalletWithBalance object',
      traceId: traceId,
    );
    final walletWithBalance = wallets.map((wallet) {
      final balance = balanceMap[wallet.account.code];
      if (balance == null) {
        return WalletWithBalance(
          wallet: wallet,
          balance: Decimal.zero,
        );
      }
      return WalletWithBalance(
        wallet: wallet,
        balance: balance.balance,
      );
    }).toList();
    return AppResult.success(walletWithBalance);
  }
}
