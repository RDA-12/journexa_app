import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/journal.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/repositories/i_journal_repository.dart';
import 'package:journexa_app/domain/repositories/i_transaction_repository.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_exception.dart';
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

/// Use case to transfer money between wallets
@lazySingleton
class TransferMoneyUseCase
    with GenerateUid, Loggable
    implements FutureBaseUseCase<TransferMoneyParams, Transaction> {
  /// Creates new [TransferMoneyUseCase]
  TransferMoneyUseCase({
    required this._journalRepository,
    required this._transactionRepository,
  });

  final IJournalRepository _journalRepository;
  final ITransactionRepository _transactionRepository;

  @override
  String get logTag => 'TransferMoneyUseCase';

  @override
  Future<AppResult<Transaction>> execute(
    TransferMoneyParams params, {
    required String traceId,
  }) async {
    logInfo(
      'Starts getting source wallet balance',
      traceId: traceId,
      extras: {
        'sourceWalletId': params.source.id,
      },
    );
    final walletBalanceResult = await _journalRepository.getCurrentBalance(
      accounts: [params.source.account],
      traceId: traceId,
    );
    final walletBalanceExc = walletBalanceResult.errorOrNull;
    if (walletBalanceExc != null) {
      logInfo(
        'Failed to get source wallet balance.',
        traceId: traceId,
      );
      return AppResult.failure(walletBalanceExc);
    }

    final walletBalance =
        walletBalanceResult.valueOrNull![params.source.account.code]!;
    final requiredAmount = params.amount + params.fee;
    logInfo(
      'Source wallet balance obtained. Check it against requested total amount',
      traceId: traceId,
      extras: {
        'walletBalance': walletBalance.balance,
        'amount': params.amount,
        'fee': params.fee,
        'requiredAmount': requiredAmount,
      },
    );
    if (walletBalance.balance < requiredAmount) {
      logInfo(
        'Source wallet balance is not enough.',
        traceId: traceId,
        extras: {
          'sourceWalletId': params.source.id,
          'walletBalance': walletBalance.balance,
          'requiredAmount': requiredAmount,
        },
      );
      return const AppResult.failure(
        AppException(
          'insufficient wallet balance',
          code: AppExceptionCode.insufficientWalletBalance,
        ),
      );
    }

    logInfo(
      'Source wallet balance is enough. '
      'Creates new transaction and journal entry',
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
      sourceWalletId: params.source.id,
      destinationWalletId: params.destination.id,
      amount: params.amount,
      fee: params.fee,
      date: params.date,
      notes: params.notes,
    );
    final journalEntry = JournalEntry(
      id: generateUid(),
      transactionDate: params.date,
      lines: [
        JournalEntryLine.fromAccount(
          account: params.source.account,
          amount: -(params.amount + params.fee),
        ),
        JournalEntryLine.fromAccount(
          account: params.destination.account,
          amount: params.amount,
        ),
        JournalEntryLine.fromAccount(
          account: SystemDefinedAccount.feeTransfer,
          amount: params.fee,
        ),
      ],
      description: params.notes,
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
