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
import 'package:journexa_app/domain/use_cases/journal/watch_current_balance.dart';
import 'package:journexa_app/domain/use_cases/journal/watch_total_mtd_expense.dart';
import 'package:journexa_app/domain/use_cases/journal/watch_total_mtd_income.dart';
import 'package:journexa_app/domain/use_cases/transaction/watch_transactions.dart';
import 'package:journexa_app/domain/use_cases/wallet/watch_wallets.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';
import 'package:journexa_app/ui/shared/event_transform/event_transform.dart';
import 'package:rxdart/rxdart.dart';

part 'home_event.dart';
part 'home_state.dart';
part 'home_bloc.freezed.dart';

/// Bloc to manage Home page
@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> with Loggable, GenerateUid {
  /// Creates new [HomeBloc]
  HomeBloc({
    required this._watchWallets,
    required this._watchAccountBalances,
    required this._watchTotalMTDIncome,
    required this._watchTotalMTDExpense,
    required this._watchTransactions,
    required this._watchIncomeCategories,
    required this._watchExpenseCategories,
  }) : super(HomeState()) {
    on<_WalletsSubscriptionRequested>(
      (event, emit) => _onWalletsSubscriptionRequested(emit: emit),
    );
    on<_MTDSubscriptionRequested>(
      (event, emit) => _onMTDDataSubscriptionRequested(
        targetDate: event.targetDate,
        wallet: event.wallet,
        emit: emit,
      ),
      transformer: debounce(),
    );
    on<_TransactionsSubscriptionRequested>(
      (event, emit) => _onTransactionsSubscriptionRequested(emit: emit),
      transformer: debounce(),
    );
  }

  final WatchWalletsUseCase _watchWallets;
  final WatchCurrentBalanceUseCase _watchAccountBalances;
  final WatchTotalMTDIncomeUseCase _watchTotalMTDIncome;
  final WatchTotalMTDExpenseUseCase _watchTotalMTDExpense;
  final WatchTransactionsUseCase _watchTransactions;
  final WatchIncomeCategoriesUseCase _watchIncomeCategories;
  final WatchExpenseCategoriesUseCase _watchExpenseCategories;


  @override
  String get logTag => 'HomeBloc';

  Future<void> _onWalletsSubscriptionRequested({
    required Emitter<HomeState> emit,
  }) async {
    final traceId = generateUid();
    logInfo(
      'Starts subscribe to required streams. '
      'Emit loading state',
      traceId: traceId,
    );
    emit(
      state.copyWith(
        wallets: const HomeWalletsUIModel(
          status: HomeUIStatus.loading,
        ),
      ),
    );

    final walletsStream = CombineLatestStream.combine2(
      _watchWallets.execute(const WatchWalletsParams(), traceId: traceId),
      _watchAccountBalances.execute(traceId: traceId),
      (walletsRes, balanceRes) {
        logInfo('New data received', traceId: traceId);
        final balanceExc = balanceRes.errorOrNull;
        if (balanceExc != null) {
          logInfo('Balance stream emits failure', traceId: traceId);
          return AppResult<List<HomeWalletUIModel>>.failure(balanceExc);
        }

        final balances = balanceRes.valueOrNull!;
        final walletsExc = walletsRes.errorOrNull;
        if (walletsExc != null) {
          logInfo('Wallets stream emits failure', traceId: traceId);
          return AppResult<List<HomeWalletUIModel>>.failure(walletsExc);
        }

        final wallets = walletsRes.valueOrNull!;
        final uiWallets = <HomeWalletUIModel>[];
        for (final wallet in wallets) {
          uiWallets.add(
            HomeWalletUIModel(
              wallet: wallet,
              balance: balances[wallet.account.code.value] ?? Decimal.zero,
            ),
          );
        }

        logInfo('All streams fine', traceId: traceId);
        return AppResult<List<HomeWalletUIModel>>.success(uiWallets);
      },
    );

    await emit.forEach(
      walletsStream,
      onData: (result) {
        return result.when(
          success: (wallets) {
            logInfo('Wallets UI model received', traceId: traceId);
            return state.copyWith(
              wallets: state.wallets.copyWith(
                wallets: wallets,
                status: HomeUIStatus.loaded,
              ),
            );
          },
          failure: (exc) {
            logError('Error received from streams', traceId: traceId);
            return state.copyWith(
              wallets: state.wallets.copyWith(
                exception: exc,
                status: HomeUIStatus.failure,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onMTDDataSubscriptionRequested({
    required DateTime targetDate,
    required Emitter<HomeState> emit,
    Wallet? wallet,
  }) async {
    final traceId = generateUid();
    logInfo(
      'Starts subscribe to total mtd for income and expense. '
      'Emits loading state',
      traceId: traceId,
    );
    emit(
      state.copyWith(
        mtdData: state.mtdData.copyWith(
          status: HomeUIStatus.loading,
        ),
      ),
    );

    final mtdStream = CombineLatestStream.combine2(
      _watchTotalMTDIncome.execute(
        WatchTotalMTDIncomeParams(
          targetDate: targetDate,
          wallet: wallet,
        ),
        traceId: traceId,
      ),
      _watchTotalMTDExpense.execute(
        WatchTotalMTDExpenseParams(
          targetDate: targetDate,
          wallet: wallet,
        ),
        traceId: traceId,
      ),
      (incomeRes, expenseRes) {
        logInfo('New MTD data received', traceId: traceId);
        final incomeExc = incomeRes.errorOrNull;
        if (incomeExc != null) {
          logInfo('Income stream emits failure', traceId: traceId);
          return AppResult<(Decimal, Decimal)>.failure(incomeExc);
        }

        final expenseExc = expenseRes.errorOrNull;
        if (expenseExc != null) {
          logInfo('Expense stream emits failure', traceId: traceId);
          return AppResult<(Decimal, Decimal)>.failure(expenseExc);
        }

        final income = incomeRes.valueOrNull!;
        final expense = expenseRes.valueOrNull!;
        return AppResult<(Decimal, Decimal)>.success((income, expense));
      },
    );

    await emit.forEach(
      mtdStream,
      onData: (result) {
        return result.when(
          success: (data) {
            return state.copyWith(
              mtdData: state.mtdData.copyWith(
                status: HomeUIStatus.loaded,
                totalIncome: data.$1,
                totalExpense: data.$2,
              ),
            );
          },
          failure: (exc) {
            return state.copyWith(
              mtdData: state.mtdData.copyWith(
                status: HomeUIStatus.failure,
                exception: exc,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onTransactionsSubscriptionRequested({
    required Emitter<HomeState> emit,
  }) async {
    final traceId = generateUid();
    logInfo(
      'Starts listening to transaction streams. '
      'Emit loading state',
      traceId: traceId,
    );
    emit(
      state.copyWith(
        transactionsData: state.transactionsData.copyWith(
          status: HomeUIStatus.loading,
        ),
      ),
    );

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
        logInfo('New transactions data received', traceId: traceId);
        final walletsExc = walletsRes.errorOrNull;
        if (walletsExc != null) {
          logInfo(
            'Wallets stream emits failure. Emit failure state',
            traceId: traceId,
          );
          return AppResult<List<HomeTransactionUIModel>>.failure(walletsExc);
        }
        final wallets = walletsRes.valueOrNull!;

        final incCatExc = incomeCategoriesRes.errorOrNull;
        if (incCatExc != null) {
          logInfo(
            'Income categories stream emits failure. Emit failure state',
            traceId: traceId,
          );
          return AppResult<List<HomeTransactionUIModel>>.failure(incCatExc);
        }
        final incCats = incomeCategoriesRes.valueOrNull!;

        final expCatExc = expenseCategoriesRes.errorOrNull;
        if (expCatExc != null) {
          logInfo(
            'Expense categories stream emits failure. Emit failure state',
            traceId: traceId,
          );
          return AppResult<List<HomeTransactionUIModel>>.failure(expCatExc);
        }
        final expCats = expenseCategoriesRes.valueOrNull!;

        final transactionsExc = transactionsRes.errorOrNull;
        if (transactionsExc != null) {
          logInfo(
            'Transactions stream emits failure. Emit failure state',
            traceId: traceId,
          );
          return AppResult<List<HomeTransactionUIModel>>.failure(
            transactionsExc,
          );
        }

        final result = <HomeTransactionUIModel>[];
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
                HomeTransactionUIModel.income(
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
                HomeTransactionUIModel.expense(
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
                    HomeTransactionUIModel.transfer(
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
          'All transaction streams fine. Emit loaded state',
          traceId: traceId,
        );
        return AppResult<List<HomeTransactionUIModel>>.success(result);
      },
    );

    await emit.forEach(
      combinedStream,
      onData: (result) {
        return result.when(
          success: (transactions) {
            return state.copyWith(
              transactionsData: state.transactionsData.copyWith(
                status: HomeUIStatus.loaded,
                transactions: transactions,
              ),
            );
          },
          failure: (exc) {
            return state.copyWith(
              transactionsData: state.transactionsData.copyWith(
                status: HomeUIStatus.failure,
                exception: exc,
              ),
            );
          },
        );
      },
    );
  }
}

