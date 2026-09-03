import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/domain/entities/journal.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/repositories/i_transaction_repository.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';

part 'add_income.freezed.dart';

/// Params for [AddIncomeUseCase]
@freezed
sealed class AddIncomeParams with _$AddIncomeParams {
  /// Creates new [AddIncomeParams]
  const factory AddIncomeParams({
    /// Wallet that will be increased by [amount]
    required Wallet wallet,

    /// Category of this income
    required IncomeCategory category,

    /// Amount of this income
    required Decimal amount,

    /// Date of this transaction
    required DateTime date,

    /// Optional notes for this transaction
    String? notes,
  }) = _AddIncomeParams;
}

/// Use case to add income record for current user
@lazySingleton
class AddIncomeUseCase
    with GenerateUid, Loggable
    implements FutureBaseUseCase<AddIncomeParams, Transaction> {
  /// Creates new [AddIncomeUseCase]
  AddIncomeUseCase({
    required this._authRepository,
    required this._transactionRepository,
  });

  final IAuthRepository _authRepository;
  final ITransactionRepository _transactionRepository;

  @override
  String get logTag => 'AddIncomeUseCase';

  @override
  Future<AppResult<Transaction>> execute(
    AddIncomeParams params, {
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
        'walletId': params.wallet.id,
        'categoryId': params.category.id,
        'amount': params.amount,
        'date': params.date,
        'notes': params.notes,
      },
    );
    final transaction = Transaction.income(
      id: generateUid(),
      walletId: params.wallet.id,
      incomeCategoryId: params.category.id,
      amount: params.amount,
      date: params.date,
    );
    final journalEntry = JournalEntry(
      id: generateUid(),
      transactionDate: params.date,
      lines: [
        JournalEntryLine.fromAccount(
          account: params.wallet.account,
          amount: params.amount,
        ),
        JournalEntryLine.fromAccount(
          account: params.category.account,
          amount: params.amount,
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
