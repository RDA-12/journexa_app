import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/repositories/i_transaction_repository.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';

part 'watch_transactions.freezed.dart';

/// Params for [WatchTransactionsUseCase]
@freezed
sealed class WatchTransactionsParams with _$WatchTransactionsParams {
  const factory WatchTransactionsParams({
    Wallet? wallet,
    int? limit,
  }) = _WatchTransactionsParams;
}

/// Use case to stream transactions
@lazySingleton
class WatchTransactionsUseCase
    with Loggable
    implements StreamBaseUseCase<WatchTransactionsParams, List<Transaction>> {
  /// Creates new [WatchTransactionsUseCase]
  WatchTransactionsUseCase({
    required this._transactionRepository,
  });

  final ITransactionRepository _transactionRepository;

  @override
  String get logTag => 'WatchTransactionsUseCase';

  @override
  Stream<AppResult<List<Transaction>>> execute(
    WatchTransactionsParams params, {
    required String traceId,
  }) {
    logInfo(
      'Starts watching transactions',
      traceId: traceId,
    );
    return _transactionRepository.watch(
      traceId: traceId,
      wallet: params.wallet,
      limit: params.limit,
    );
  }
}
