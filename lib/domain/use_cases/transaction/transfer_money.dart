import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/entities/journal.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/repositories/i_transaction_repository.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';

part 'transfer_money.freezed.dart';

/// Params for [TransferMoneyUseCase]
@freezed
sealed class TransferMoneyParams with _$TransferMoneyParams {
  /// Creates new [TransferMoneyParams]
  const factory TransferMoneyParams({
    /// Source wallet of this transfer
    required Wallet source,

    /// Destination wallet of this transfer
    required Wallet destination,

    /// Amount of this transfer
    required Decimal amount,

    /// Fee of this transfer
    required Decimal fee,

    /// Date of this transaction
    required DateTime date,

    /// Optional notes for this transaction
    String? notes,
  }) = _TransferMoneyParams;
}

/// Use case to transfer money between wallets for current user
@lazySingleton
class TransferMoneyUseCase
    with GenerateUid, Loggable
    implements FutureBaseUseCase<TransferMoneyParams, Transaction> {
  /// Creates new [TransferMoneyUseCase]
  TransferMoneyUseCase({
    required this._authRepository,
    required this._transactionRepository,
  });

  final IAuthRepository _authRepository;
  final ITransactionRepository _transactionRepository;

  @override
  String get logTag => 'TransferMoneyUseCase';

  @override
  Future<AppResult<Transaction>> execute(
    TransferMoneyParams params, {
    required String traceId,
  }) async {
    logInfo(
      'Starts getting current user id',
      traceId: traceId,
    );
    final getCurrentUserIdResult = await _authRepository.getCurrentUserId(
      traceId: traceId,
    );
    final getCurrentUserIdExc = getCurrentUserIdResult.errorOrNull;
    if (getCurrentUserIdExc != null) {
      logInfo(
        'Failed to get current user id.',
        traceId: traceId,
      );
      return AppResult.failure(getCurrentUserIdExc);
    }

    final userId = getCurrentUserIdResult.valueOrNull!;
    logInfo(
      'User ID obtained. Creates new transaction and journal entry',
      traceId: traceId,
      extras: {
        'sourceWalletId': params.source.id,
        'destinationWalletId': params.destination.id,
        'amount': params.amount,
        'fee': params.fee,
        'date': params.date,
        'notes': params.notes,
      },
    );
    final transaction = Transaction.transfer(
      id: generateUid(),
      source: params.source,
      destination: params.destination,
      amount: params.amount,
      fee: params.fee,
      date: params.date,
      notes: params.notes,
    );
    final journalEntry = JournalEntry.fromTransaction(
      id: generateUid(),
      transaction: transaction,
    );
    logInfo(
      'Transaction and journal entry created. Saves them to repository',
      traceId: traceId,
      extras: {
        'transactionId': transaction.id,
        'journalEntryId': journalEntry.id,
      },
    );
    final saveResult = await _transactionRepository.save(
      userId: userId,
      transaction: transaction,
      journalEntry: journalEntry,
      traceId: traceId,
    );
    final saveExc = saveResult.errorOrNull;
    if (saveExc != null) {
      logInfo(
        'Failed to save transaction and journal entry.',
        traceId: traceId,
      );
      return AppResult.failure(saveExc);
    }
    logInfo(
      'Transaction and journal entry saved successfully.',
      traceId: traceId,
    );
    return AppResult.success(transaction);
  }
}
