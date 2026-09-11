import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/shared/app_result.dart';

/// Repository to handle all operations related to [Wallet]
abstract interface class IWalletRepository {
  /// Save [wallet] in database
  Future<AppResult<Null>> save({
    required Wallet wallet,
    required String traceId,
  });

  /// Returns list of [Wallet] from database
  ///
  /// If [query] is provided, returns list of [Wallet] that contains [query]
  Stream<AppResult<List<Wallet>>> watch({
    required String traceId,
    String? query,
    bool? isDeleted,
  });

  /// Delete [wallet] from database
  Future<AppResult<Null>> delete({
    required Wallet wallet,
    required String traceId,
  });

  /// Update [updatedWallet] in database
  Future<AppResult<Null>> update({
    required Wallet updatedWallet,
    required String traceId,
  });
}
