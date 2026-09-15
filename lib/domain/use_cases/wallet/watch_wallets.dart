import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/repositories/i_wallet_respository.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';

part 'watch_wallets.freezed.dart';

/// Params for [WatchWalletsUseCase]
@freezed
sealed class WatchWalletsParams with _$WatchWalletsParams {
  const factory({
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
  new({
    required this._walletRepository,
  });

  @override
  String get logTag => 'WatchWalletsUseCase';

  final IWalletRepository _walletRepository;

  /// Execute getting stream of wallets from current user
  @override
  Stream<AppResult<List<Wallet>>> execute(
    WatchWalletsParams params, {
    required String traceId,
  }) {
    logInfo('Starts watching wallets', traceId: traceId);
    return _walletRepository.watch(
      query: params.query,
      traceId: traceId,
      isDeleted: false,
    );
  }
}
