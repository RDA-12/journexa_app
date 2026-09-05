import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/repositories/i_wallet_respository.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';

part 'watch_wallets.freezed.dart';

/// Params for [WatchWalletsUseCase]
@freezed
sealed class WatchWalletsParams with _$WatchWalletsParams {
  const factory WatchWalletsParams({
    String? query,
  }) = _WatchWalletsParams;
}

/// Use case to stream Wallets and their balances saved on
/// current user database
@lazySingleton
class WatchWalletsUseCase
    with Loggable
    implements StreamBaseUseCase<WatchWalletsParams, List<Wallet>> {
  /// Creates new [WatchWalletsUseCase]
  WatchWalletsUseCase({
    required this._walletRepository,
    required this._authRepository,
  });

  @override
  String get logTag => 'WatchWalletsUseCase';

  final IAuthRepository _authRepository;
  final IWalletRepository _walletRepository;

  /// Execute getting stream of wallets from current user
  @override
  Stream<AppResult<List<Wallet>>> execute(
    WatchWalletsParams params, {
    required String traceId,
  }) async* {
    logInfo('Starts getting current user id ', traceId: traceId);
    final currentUserIdResult = await _authRepository.getCurrentUserId(
      traceId: traceId,
    );
    final currentUserIdExc = currentUserIdResult.errorOrNull;
    if (currentUserIdExc != null) {
      logInfo('Failed to get current user id', traceId: traceId);
      yield AppResult.failure(currentUserIdExc);
      return;
    }

    final userId = currentUserIdResult.valueOrNull!;
    logInfo('Got current user id. Starts watching wallets', traceId: traceId);
    yield* _walletRepository.watch(
      userId: userId,
      query: params.query,
      traceId: traceId,
      isDeleted: false,
    );
  }
}
