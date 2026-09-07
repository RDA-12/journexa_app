import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/entities/expense_category.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/use_cases/expense_category/watch_expense_categories.dart';
import 'package:journexa_app/domain/use_cases/income_category/watch_income_categories.dart';
import 'package:journexa_app/domain/use_cases/transaction/watch_transactions.dart';
import 'package:journexa_app/domain/use_cases/wallet/watch_wallets.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';
import 'package:journexa_app/ui/shared/event_transform/debounce.dart';
import 'package:rxdart/rxdart.dart';

part 'transactions_event.dart';
part 'transactions_state.dart';
part 'transactions_bloc.freezed.dart';

/// BLoc to handles [Transaction] data
@injectable
class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState>
    with Loggable, GenerateUid {
  /// Creates new [TransactionsBloc]
  TransactionsBloc({
    required this._watchTransactions,
    required this._watchWallets,
    required this._watchIncomeCategories,
    required this._watchExpenseCategories,
  }) : super(const TransactionsState.initial()) {
    on<_SubscriptionRequested>(
      (event, emit) => _onSubscriptionRequested(emit),
      transformer: debounce(),
    );
  }

  @override
  String get logTag => 'TransactionsBloc';

  final WatchTransactionsUseCase _watchTransactions;
  final WatchWalletsUseCase _watchWallets;
  final WatchIncomeCategoriesUseCase _watchIncomeCategories;
  final WatchExpenseCategoriesUseCase _watchExpenseCategories;

  Future<void> _onSubscriptionRequested(
    Emitter<TransactionsState> emit,
  ) async {
    final traceId = generateUid();
    logInfo(
      'Starts listening to streams. Emit loading state',
      traceId: traceId,
    );
    emit(const TransactionsState.loading());

    final combinedStream = CombineLatestStream.combine4(
      _watchTransactions.execute(traceId: traceId),
      _watchWallets.execute(const WatchWalletsParams(), traceId: traceId),
      _watchIncomeCategories.execute(
        const WatchIncomeCategoriesParams(),
        traceId: traceId,
      ),
      _watchExpenseCategories.execute(
        const WatchExpenseCategoriesParams(),
        traceId: traceId,
      ),
      (transactionsRes, walletsRes, incomeCategoriesRes, expenseCategoriesRes) {
        logInfo('New data received', traceId: traceId);
        final walletsExc = walletsRes.errorOrNull;
        if (walletsExc != null) {
          logInfo(
            'Wallets stream emits failure. Emit failure state',
            traceId: traceId,
          );
          return AppResult<List<TransactionUIModel>>.failure(walletsExc);
        }
        final wallets = walletsRes.valueOrNull!;

        final incCatExc = incomeCategoriesRes.errorOrNull;
        if (incCatExc != null) {
          logInfo(
            'Income categories stream emits failure. Emit failure state',
            traceId: traceId,
          );
          return AppResult<List<TransactionUIModel>>.failure(incCatExc);
        }
        final incCats = incomeCategoriesRes.valueOrNull!;

        final expCatExc = expenseCategoriesRes.errorOrNull;
        if (expCatExc != null) {
          logInfo(
            'Expense categories stream emits failure. Emit failure state',
            traceId: traceId,
          );
          return AppResult<List<TransactionUIModel>>.failure(expCatExc);
        }
        final expCats = expenseCategoriesRes.valueOrNull!;

        final transactionsExc = transactionsRes.errorOrNull;
        if (transactionsExc != null) {
          logInfo(
            'Transactions stream emits failure. Emit failure state',
            traceId: traceId,
          );
          return AppResult<List<TransactionUIModel>>.failure(transactionsExc);
        }

        final result = <TransactionUIModel>[];
        final transactions = transactionsRes.valueOrNull!;
        for (final tr in transactions) {
          tr.when(
            income: (id, walletId, categoryId, amount, date, notes) {
              final wallet = wallets.firstWhereOrNull(
                (it) => it.id == walletId,
              );
              final category = incCats.firstWhereOrNull(
                (it) => it.id == categoryId,
              );
              if (wallet == null || category == null) {
                logWarning(
                  'Wallet or category not found for income transaction',
                  traceId: traceId,
                );
                return;
              }
              result.add(
                TransactionUIModel.income(
                  id: id,
                  wallet: wallet,
                  category: category,
                  amount: amount,
                  date: date,
                  notes: notes,
                ),
              );
            },
            expense: (id, walletId, categoryId, amount, date, notes) {
              final wallet = wallets.firstWhereOrNull(
                (it) => it.id == walletId,
              );
              final category = expCats.firstWhereOrNull(
                (it) => it.id == categoryId,
              );
              if (wallet == null || category == null) {
                logWarning(
                  'Wallet or category not found for expense transaction',
                  traceId: traceId,
                );
                return;
              }
              result.add(
                TransactionUIModel.expense(
                  id: id,
                  wallet: wallet,
                  category: category,
                  amount: amount,
                  date: date,
                  notes: notes,
                ),
              );
            },
            transfer:
                (
                  id,
                  sourceWalletId,
                  destinationWalletId,
                  amount,
                  fee,
                  date,
                  notes,
                ) {
                  final sourceWallet = wallets.firstWhereOrNull(
                    (it) => it.id == sourceWalletId,
                  );
                  final destinationWallet = wallets.firstWhereOrNull(
                    (it) => it.id == destinationWalletId,
                  );
                  if (sourceWallet == null || destinationWallet == null) {
                    logWarning(
                      'Wallet or category not found for transfer transaction',
                      traceId: traceId,
                    );
                    return;
                  }
                  result.add(
                    TransactionUIModel.transfer(
                      id: id,
                      sourceWallet: sourceWallet,
                      destinationWallet: destinationWallet,
                      amount: amount,
                      fee: fee,
                      date: date,
                      notes: notes,
                    ),
                  );
                },
          );
        }

        logInfo(
          'All streams emit success. Emit loaded state',
          traceId: traceId,
        );
        return AppResult<List<TransactionUIModel>>.success(result);
      },
    );

    await emit.forEach(
      combinedStream,
      onData: (result) {
        return result.when(
          success: (transactions) {
            return TransactionsState.loaded(transactions);
          },
          failure: (error) {
            return TransactionsState.failure(error);
          },
        );
      },
    );
  }
}
