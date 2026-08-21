import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/shared/app_result.dart';

/// Repository to handle all operations related to [Wallet]
abstract interface class IWalletRepository {
  /// Save [wallet] within [userId] database
  Future<AppResult<Null>> save({
    required String userId,
    required Wallet wallet,
    required String traceId,
  });

  /// Returns list of [Wallet] within [userId] database
  ///
  /// If [query] is provided, returns list of [Wallet] that contains [query]
  Future<AppResult<List<Wallet>>> getAll({
    required String userId,
    required String traceId,
    String? query,
  });
}
