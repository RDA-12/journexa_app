import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/repositories/i_wallet_respository.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';

part 'delete_wallet.freezed.dart';

/// Params for [DeleteWalletUseCase]
@freezed
sealed class DeleteWalletParams with _$DeleteWalletParams {
  /// Creates new [DeleteWalletParams]
  const factory({
    /// [Wallet] that will be deleted
    required Wallet wallet,
  }) = _DeleteWalletsParams;
}

/// Use Case to delete a wallet in current user database
@lazySingleton
class DeleteWalletUseCase
    with Loggable
    implements FutureBaseUseCase<DeleteWalletParams, Null> {
  /// Creates new [DeleteWalletUseCase]
  new({
    required this._walletRepository,
  });

  @override
  String get logTag => 'DeleteWalletUseCase';

  final IWalletRepository _walletRepository;

  /// Execute deletting wallet in [params] for current user
  @override
  Future<AppResult<Null>> execute(
    DeleteWalletParams params, {
    required String traceId,
  }) async {
    logInfo('Starts deleting wallet', traceId: traceId);
    final deleteResult = await _walletRepository.delete(
      wallet: params.wallet,
      traceId: traceId,
    );
    final deleteExc = deleteResult.errorOrNull;
    if (deleteExc != null) {
      logInfo('Failed to delete wallet', traceId: traceId);
      return AppResult.failure(deleteExc);
    }

    logInfo('Wallet deleted successfully', traceId: traceId);
    return const AppResult.success(null);
  }
}
