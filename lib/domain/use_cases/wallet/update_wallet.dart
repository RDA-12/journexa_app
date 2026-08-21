import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/repositories/i_wallet_respository.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';

part 'update_wallet.freezed.dart';

/// Params for [UpdateWalletUseCase]
@freezed
sealed class UpdateWalletParams with _$UpdateWalletParams {
  const factory UpdateWalletParams({
    /// Wallet code that will be updated
    required Wallet wallet,

    /// Optional new name
    String? name,
  }) = _UpdateWalletParams;
}

/// Use case to update existing [Wallet] for current user
@lazySingleton
class UpdateWalletUseCase
    with Loggable
    implements FutureBaseUseCase<UpdateWalletParams, Wallet> {
  /// Creates new [UpdateWalletUseCase]
  UpdateWalletUseCase({
    required this._authRepository,
    required this._walletRepository,
  });

  @override
  String get logTag => 'UpdateWalletUseCase';

  final IAuthRepository _authRepository;
  final IWalletRepository _walletRepository;

  /// Execute updating an [Wallet]
  @override
  Future<AppResult<Wallet>> execute(
    UpdateWalletParams params, {
    required String traceId,
  }) async {
    logInfo('Start getting current user id', traceId: traceId);
    final userIdResult = await _authRepository.getCurrentUserId(
      traceId: traceId,
    );
    final userIdExc = userIdResult.errorOrNull;
    if (userIdExc != null) {
      logInfo('Failed to get current user id', traceId: traceId);
      return AppResult.failure(userIdExc);
    }

    logInfo(
      'User id obtained. Starts updating the Wallet',
      traceId: traceId,
      extras: {
        'id': params.wallet.id,
      },
    );
    final userId = userIdResult.valueOrNull!;
    final updatedWallet = params.wallet.update(
      name: params.name,
    );
    final saveResult = await _walletRepository.update(
      userId: userId,
      updatedWallet: updatedWallet,
      traceId: traceId,
    );
    final saveExc = saveResult.errorOrNull;
    if (saveExc != null) {
      logInfo('Failed to save updated wallet', traceId: traceId);
      return AppResult.failure(saveExc);
    }

    logInfo('Updated wallet saved. Finishing', traceId: traceId);
    return AppResult.success(updatedWallet);
  }
}
