import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/entities/expense_category.dart';
import 'package:journexa_app/domain/entities/journal.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/repositories/i_journal_repository.dart';
import 'package:journexa_app/domain/repositories/i_transaction_repository.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';

part 'add_expense.freezed.dart';

/// Params for [AddExpenseUseCase]
@freezed
sealed class AddExpenseParams with _$AddExpenseParams {
  /// Creates new [AddExpenseParams]
  const factory AddExpenseParams({
    /// Wallet that will be decreased by [amount]
    required Wallet wallet,

    /// Category of this expense
    required ExpenseCategory category,

    /// Amount of this expense
    required Decimal amount,

    /// Date of this transaction
    required DateTime date,

    /// Optional notes for this transaction
    String? notes,
  }) = _AddExpenseParams;
}

/// Use case to add expense record for current user
@lazySingleton
class AddExpenseUseCase
    with GenerateUid, Loggable
    implements FutureBaseUseCase<AddExpenseParams, Transaction> {
  /// Creates new [AddExpenseUseCase]
  AddExpenseUseCase({
    required this._authRepository,
    required this._journalRepository,
    required this._transactionRepository,
  });

  final IAuthRepository _authRepository;
  final IJournalRepository _journalRepository;
  final ITransactionRepository _transactionRepository;

  @override
  String get logTag => 'AddExpenseUseCase';

  @override
  Future<AppResult<Transaction>> execute(
    AddExpenseParams params, {
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
      'User ID obtained. Get Wallet balance',
      traceId: traceId,
      extras: {
        'walletId': params.wallet.id,
      },
    );
    final walletBalanceResult = await _journalRepository.getCurrentBalance(
      userId: userId,
      accounts: [params.wallet.account],
      traceId: traceId,
    );
    final walletBalanceExc = walletBalanceResult.errorOrNull;
    if (walletBalanceExc != null) {
      logInfo(
        'Failed to get wallet balance.',
        traceId: traceId,
      );
      return AppResult.failure(walletBalanceExc);
    }

    final walletBalance =
        walletBalanceResult.valueOrNull![params.wallet.account.code]!;
    logInfo(
      'Wallet balance obtained. Check it against requested amount',
      traceId: traceId,
      extras: {
        'walletBalance': walletBalance.balance,
        'amount': params.amount,
      },
    );
    if (walletBalance.balance < params.amount) {
      logInfo(
        'Wallet balance is not enough.',
        traceId: traceId,
        extras: {
          'walletId': params.wallet.id,
          'walletBalance': walletBalance.balance,
          'amount': params.amount,
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
      'Wallet balance is enough. Creates transaction and journal entry',
      traceId: traceId,
      extras: {
        'walletId': params.wallet.id,
        'categoryId': params.category.id,
        'amount': params.amount,
        'date': params.date,
        'notes': params.notes,
      },
    );
    final transaction = Transaction.expense(
      id: generateUid(),
      wallet: params.wallet,
      category: params.category,
      amount: params.amount,
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
