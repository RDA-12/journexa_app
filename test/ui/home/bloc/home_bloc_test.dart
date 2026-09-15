import 'package:bloc_test/bloc_test.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
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
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';
import 'package:journexa_app/ui/home/bloc/home_bloc.dart';
import 'package:journexa_app/ui/shared/event_transform/event_transform.dart';
import 'package:journexa_app/ui/shared/models/transaction_ui_model.dart';
import 'package:mocktail/mocktail.dart';

class MockWatchWalletsUseCase extends Mock implements WatchWalletsUseCase {}

class MockWatchCurrentBalanceUseCase extends Mock
    implements WatchCurrentBalanceUseCase {}

class MockUidGenerator extends Mock implements UidGenerator {}

class MockWatchTotalMTDIncomeUseCase extends Mock
    implements WatchTotalMTDIncomeUseCase {}

class MockWatchTotalMTDExpenseUseCase extends Mock
    implements WatchTotalMTDExpenseUseCase {}

class MockWatchTransactionsUseCase extends Mock
    implements WatchTransactionsUseCase {}

class MockWatchIncomeCategoriesUseCase extends Mock
    implements WatchIncomeCategoriesUseCase {}

class MockWatchExpenseCategoriesUseCase extends Mock
    implements WatchExpenseCategoriesUseCase {}

void main() {
  const traceId = 'traceId';
  final date = DateTime(2026);
  final assetParent = SystemDefinedAccount.walletParent;
  final wallets = List.generate(5, (idx) {
    return Wallet(
      id: '$idx',
      name: 'asset $idx',
      account: Account.sub(
        name: 'asset $idx',
        parent: assetParent,
        currentChildrenCount: idx,
      ),
    );
  });
  final currentBalances = <String, Decimal>{
    for (final wallet in wallets)
      wallet.account.code.value: Decimal.fromInt(int.parse(wallet.id) * 1000),
  };
  final walletsWithState = List.generate(5, (idx) {
    return HomeWalletUIModel(
      wallet: wallets[idx],
      balance: Decimal.fromInt(idx * 1000),
    );
  });
  final mtdTargetDate = DateTime.now();
  final watchMTDIncomeParams = WatchTotalMTDIncomeParams(
    targetDate: mtdTargetDate,
  );
  final watchMTDExpenseParams = WatchTotalMTDExpenseParams(
    targetDate: mtdTargetDate,
  );
  final totalMTDIncome = Decimal.fromInt(1000);
  final totalMTDExpense = Decimal.fromInt(500);

  final incomeCategory = IncomeCategory(
    id: 'inc-cat-1',
    name: 'Salary',
    icon: 'salary_icon',
    account: Account.sub(
      parent: SystemDefinedAccount.incomeParent,
      name: 'Salary',
      currentChildrenCount: 0,
    ),
  );

  final expenseCategory = ExpenseCategory(
    id: 'exp-cat-1',
    name: 'Groceries',
    icon: 'groceries_icon',
    account: Account.sub(
      parent: SystemDefinedAccount.expenseParent,
      name: 'Groceries',
      currentChildrenCount: 0,
    ),
  );

  final incomeTransaction = IncomeTransaction(
    id: 'tr-income-1',
    walletId: wallets[0].id,
    incomeCategoryId: incomeCategory.id,
    amount: Decimal.fromInt(500),
    date: date,
    notes: 'Income note',
  );

  final expenseTransaction = ExpenseTransaction(
    id: 'tr-expense-1',
    walletId: wallets[0].id,
    expenseCategoryId: expenseCategory.id,
    amount: Decimal.fromInt(200),
    date: date,
    notes: 'Expense note',
  );

  final transferTransaction = TransferTransaction(
    id: 'tr-transfer-1',
    sourceWalletId: wallets[0].id,
    destinationWalletId: wallets[1].id,
    amount: Decimal.fromInt(300),
    fee: Decimal.fromInt(5),
    date: date,
    notes: 'Transfer note',
  );

  final transactions = <Transaction>[
    incomeTransaction,
    expenseTransaction,
    transferTransaction,
  ];

  final expectedTransactionsUI = <TransactionUIModel>[
    TransactionUIModel.income(
      id: incomeTransaction.id,
      wallet: wallets[0],
      category: incomeCategory,
      amount: incomeTransaction.amount,
      date: incomeTransaction.date,
      notes: incomeTransaction.notes,
    ),
    TransactionUIModel.expense(
      id: expenseTransaction.id,
      wallet: wallets[0],
      category: expenseCategory,
      amount: expenseTransaction.amount,
      date: expenseTransaction.date,
      notes: expenseTransaction.notes,
    ),
    TransactionUIModel.transfer(
      id: transferTransaction.id,
      sourceWallet: wallets[0],
      destinationWallet: wallets[1],
      amount: transferTransaction.amount,
      fee: transferTransaction.fee,
      date: transferTransaction.date,
      notes: transferTransaction.notes,
    ),
  ];

  late WatchWalletsUseCase mockWatchWallets;
  late WatchCurrentBalanceUseCase mockWatchCurrentBalance;
  late UidGenerator mockUidGenerator;
  late WatchTotalMTDIncomeUseCase mockWatchTotalMTDIncome;
  late WatchTotalMTDExpenseUseCase mockWatchTotalMTDExpense;
  late WatchTransactionsUseCase mockWatchTransactions;
  late WatchIncomeCategoriesUseCase mockWatchIncomeCategories;
  late WatchExpenseCategoriesUseCase mockWatchExpenseCategories;

  setUpAll(() {
    registerFallbackValue(
      const WatchWalletsParams(),
    );
    registerFallbackValue(watchMTDIncomeParams);
    registerFallbackValue(watchMTDExpenseParams);
    registerFallbackValue(const WatchIncomeCategoriesParams());
    registerFallbackValue(const WatchExpenseCategoriesParams());
    registerFallbackValue(const WatchTransactionsParams());
  });

  setUp(() {
    mockUidGenerator = MockUidGenerator();
    when(mockUidGenerator.generateUid).thenReturn(traceId);

    mockWatchWallets = MockWatchWalletsUseCase();
    when(
      () => mockWatchWallets.execute(
        any<WatchWalletsParams>(),
        traceId: traceId,
      ),
    ).thenAnswer(
      (_) => Stream.value(AppResult.success(wallets)),
    );

    mockWatchCurrentBalance = MockWatchCurrentBalanceUseCase();
    when(
      () => mockWatchCurrentBalance.execute(traceId: traceId),
    ).thenAnswer(
      (_) => Stream.value(AppResult.success(currentBalances)),
    );

    mockWatchTotalMTDIncome = MockWatchTotalMTDIncomeUseCase();
    when(
      () => mockWatchTotalMTDIncome.execute(
        any<WatchTotalMTDIncomeParams>(),
        traceId: traceId,
      ),
    ).thenAnswer((_) => Stream.value(AppResult.success(totalMTDIncome)));

    mockWatchTotalMTDExpense = MockWatchTotalMTDExpenseUseCase();
    when(
      () => mockWatchTotalMTDExpense.execute(
        any<WatchTotalMTDExpenseParams>(),
        traceId: traceId,
      ),
    ).thenAnswer((_) => Stream.value(AppResult.success(totalMTDExpense)));

    mockWatchTransactions = MockWatchTransactionsUseCase();
    when(
      () => mockWatchTransactions.execute(
        any(),
        traceId: traceId,
      ),
    ).thenAnswer((_) => Stream.value(AppResult.success(transactions)));

    mockWatchIncomeCategories = MockWatchIncomeCategoriesUseCase();
    when(
      () => mockWatchIncomeCategories.execute(
        any<WatchIncomeCategoriesParams>(),
        traceId: traceId,
      ),
    ).thenAnswer((_) => Stream.value(AppResult.success([incomeCategory])));

    mockWatchExpenseCategories = MockWatchExpenseCategoriesUseCase();
    when(
      () => mockWatchExpenseCategories.execute(
        any<WatchExpenseCategoriesParams>(),
        traceId: traceId,
      ),
    ).thenAnswer((_) => Stream.value(AppResult.success([expenseCategory])));
  });

  HomeBloc buildBloc() {
    return HomeBloc(
      watchWallets: mockWatchWallets,
      watchAccountBalances: mockWatchCurrentBalance,
      watchTotalMTDIncome: mockWatchTotalMTDIncome,
      watchTotalMTDExpense: mockWatchTotalMTDExpense,
      watchTransactions: mockWatchTransactions,
      watchIncomeCategories: mockWatchIncomeCategories,
      watchExpenseCategories: mockWatchExpenseCategories,
    )..customGenerator = mockUidGenerator;
  }

  test('has initial state of HomeState()', () {
    final bloc = buildBloc();
    expect(bloc.state, HomeState());
  });

  group('walletsSubscriptionRequested', () {
    group('wallets', () {
      blocTest<HomeBloc, HomeState>(
        'emits [loading, loaded] '
        'with correct wallet balances '
        'when all watch use cases return success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          const HomeEvent.walletsSubscriptionRequested(),
        ),
        expect: () => <HomeState>[
          HomeState(
            wallets: const HomeWalletsUIModel(
              status: HomeUIStatus.loading,
            ),
          ),
          HomeState(
            wallets: HomeWalletsUIModel(
              status: HomeUIStatus.loaded,
              wallets: walletsWithState,
            ),
          ),
        ],
        verify: (_) {
          verify(
            () => mockWatchWallets.execute(
              const WatchWalletsParams(),
              traceId: traceId,
            ),
          ).called(1);
          verify(
            () => mockWatchCurrentBalance.execute(traceId: traceId),
          ).called(1);
        },
      );

      blocTest<HomeBloc, HomeState>(
        'defaults wallet balance to Decimal.zero '
        'when wallet account code is missing from currentBalances',
        setUp: () {
          when(
            () => mockWatchCurrentBalance.execute(traceId: traceId),
          ).thenAnswer(
            (_) => Stream.value(const AppResult.success(<String, Decimal>{})),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          const HomeEvent.walletsSubscriptionRequested(),
        ),
        expect: () => <HomeState>[
          HomeState(
            wallets: const HomeWalletsUIModel(
              status: HomeUIStatus.loading,
            ),
          ),
          HomeState(
            wallets: HomeWalletsUIModel(
              status: HomeUIStatus.loaded,
              wallets: wallets
                  .map(
                    (w) => HomeWalletUIModel(wallet: w, balance: Decimal.zero),
                  )
                  .toList(),
            ),
          ),
        ],
      );

      blocTest<HomeBloc, HomeState>(
        'emits [loading, failure] '
        'when watchWallets emits failure',
        setUp: () {
          when(
            () => mockWatchWallets.execute(
              const WatchWalletsParams(),
              traceId: traceId,
            ),
          ).thenAnswer(
            (_) => Stream.value(
              AppResult<List<Wallet>>.failure(AppException.test()),
            ),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          const HomeEvent.walletsSubscriptionRequested(),
        ),
        expect: () => <HomeState>[
          HomeState(
            wallets: const HomeWalletsUIModel(
              status: HomeUIStatus.loading,
            ),
          ),
          HomeState(
            wallets: HomeWalletsUIModel(
              status: HomeUIStatus.failure,
              exception: AppException.test(),
            ),
          ),
        ],
        verify: (_) {
          verify(
            () => mockWatchWallets.execute(
              const WatchWalletsParams(),
              traceId: traceId,
            ),
          ).called(1);
        },
      );

      blocTest<HomeBloc, HomeState>(
        'emits [loading, failure] '
        'when watchAccountBalances emits failure',
        setUp: () {
          when(
            () => mockWatchCurrentBalance.execute(traceId: traceId),
          ).thenAnswer(
            (_) => Stream.value(
              AppResult<Map<String, Decimal>>.failure(AppException.test()),
            ),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          const HomeEvent.walletsSubscriptionRequested(),
        ),
        expect: () => <HomeState>[
          HomeState(
            wallets: const HomeWalletsUIModel(
              status: HomeUIStatus.loading,
            ),
          ),
          HomeState(
            wallets: HomeWalletsUIModel(
              status: HomeUIStatus.failure,
              exception: AppException.test(),
            ),
          ),
        ],
        verify: (_) {
          verify(
            () => mockWatchCurrentBalance.execute(traceId: traceId),
          ).called(1);
        },
      );
    });
  });

  group('mtdSubscriptionRequested', () {
    blocTest<HomeBloc, HomeState>(
      'emits [loading, loaded] '
      'with correct total income and expense '
      'when all watch mtd data success',
      build: buildBloc,
      act: (bloc) => bloc.add(
        HomeEvent.mtdSubscriptionRequested(
          targetDate: mtdTargetDate,
        ),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <HomeState>[
        HomeState(
          mtdData: HomeMTDDataUIModel(
            status: HomeUIStatus.loading,
            totalIncome: Decimal.zero,
            totalExpense: Decimal.zero,
          ),
        ),
        HomeState(
          mtdData: HomeMTDDataUIModel(
            status: HomeUIStatus.loaded,
            totalIncome: totalMTDIncome,
            totalExpense: totalMTDExpense,
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => mockWatchTotalMTDIncome.execute(
            watchMTDIncomeParams,
            traceId: traceId,
          ),
        ).called(1);
        verify(
          () => mockWatchTotalMTDExpense.execute(
            watchMTDExpenseParams,
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'calls correct WatchTotalMTDIncome and WatchTotalMTDExpense '
      'when wallet filter provided',
      build: buildBloc,
      act: (bloc) => bloc.add(
        HomeEvent.mtdSubscriptionRequested(
          targetDate: mtdTargetDate,
          wallet: wallets.first,
        ),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <HomeState>[
        HomeState(
          mtdData: HomeMTDDataUIModel(
            status: HomeUIStatus.loading,
            totalIncome: Decimal.zero,
            totalExpense: Decimal.zero,
          ),
        ),
        HomeState(
          mtdData: HomeMTDDataUIModel(
            status: HomeUIStatus.loaded,
            totalIncome: totalMTDIncome,
            totalExpense: totalMTDExpense,
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => mockWatchTotalMTDIncome.execute(
            watchMTDIncomeParams.copyWith(wallet: wallets.first),
            traceId: traceId,
          ),
        ).called(1);
        verify(
          () => mockWatchTotalMTDExpense.execute(
            watchMTDExpenseParams.copyWith(wallet: wallets.first),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'uses debounce event transformer',
      build: buildBloc,
      act: (bloc) async {
        for (final wallet in wallets) {
          bloc.add(
            HomeEvent.mtdSubscriptionRequested(
              targetDate: mtdTargetDate,
              wallet: wallet,
            ),
          );
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
      },
      wait: kDefaultDebounceDuration,
      expect: () => <HomeState>[
        HomeState(
          mtdData: HomeMTDDataUIModel(
            status: HomeUIStatus.loading,
            totalIncome: Decimal.zero,
            totalExpense: Decimal.zero,
          ),
        ),
        HomeState(
          mtdData: HomeMTDDataUIModel(
            status: HomeUIStatus.loaded,
            totalIncome: totalMTDIncome,
            totalExpense: totalMTDExpense,
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => mockWatchTotalMTDIncome.execute(
            watchMTDIncomeParams.copyWith(wallet: wallets.last),
            traceId: traceId,
          ),
        ).called(1);
        verify(
          () => mockWatchTotalMTDExpense.execute(
            watchMTDExpenseParams.copyWith(wallet: wallets.last),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'emits [loading, failure] '
      'when watchTotalMTDIncome emits failure',
      setUp: () {
        when(
          () => mockWatchTotalMTDIncome.execute(
            watchMTDIncomeParams,
            traceId: traceId,
          ),
        ).thenAnswer(
          (_) => Stream.value(
            AppResult<Decimal>.failure(AppException.test()),
          ),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        HomeEvent.mtdSubscriptionRequested(
          targetDate: mtdTargetDate,
        ),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <HomeState>[
        HomeState(
          mtdData: HomeMTDDataUIModel(
            status: HomeUIStatus.loading,
            totalIncome: Decimal.zero,
            totalExpense: Decimal.zero,
          ),
        ),
        HomeState(
          mtdData: HomeMTDDataUIModel(
            status: HomeUIStatus.failure,
            totalIncome: Decimal.zero,
            totalExpense: Decimal.zero,
            exception: AppException.test(),
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => mockWatchTotalMTDIncome.execute(
            watchMTDIncomeParams,
            traceId: traceId,
          ),
        ).called(1);
        verify(
          () => mockWatchTotalMTDExpense.execute(
            watchMTDExpenseParams,
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'emits [loading, failure] '
      'when watchTotalMTDExpense emits failure',
      setUp: () {
        when(
          () => mockWatchTotalMTDExpense.execute(
            watchMTDExpenseParams,
            traceId: traceId,
          ),
        ).thenAnswer(
          (_) => Stream.value(
            AppResult<Decimal>.failure(AppException.test()),
          ),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        HomeEvent.mtdSubscriptionRequested(
          targetDate: mtdTargetDate,
        ),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <HomeState>[
        HomeState(
          mtdData: HomeMTDDataUIModel(
            status: HomeUIStatus.loading,
            totalIncome: Decimal.zero,
            totalExpense: Decimal.zero,
          ),
        ),
        HomeState(
          mtdData: HomeMTDDataUIModel(
            status: HomeUIStatus.failure,
            totalIncome: Decimal.zero,
            totalExpense: Decimal.zero,
            exception: AppException.test(),
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => mockWatchTotalMTDIncome.execute(
            watchMTDIncomeParams,
            traceId: traceId,
          ),
        ).called(1);
        verify(
          () => mockWatchTotalMTDExpense.execute(
            watchMTDExpenseParams,
            traceId: traceId,
          ),
        ).called(1);
      },
    );
  });

  group('transactionsSubscriptionRequested', () {
    blocTest<HomeBloc, HomeState>(
      'emits [loading, loaded] '
      'with correct mapped transactions '
      'when all watch use cases return success',
      build: buildBloc,
      act: (bloc) => bloc.add(
        const HomeEvent.transactionsSubscriptionRequested(),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <HomeState>[
        HomeState(
          transactionsData: const HomeTransactionsUIModel(
            status: HomeUIStatus.loading,
          ),
        ),
        HomeState(
          transactionsData: HomeTransactionsUIModel(
            status: HomeUIStatus.loaded,
            transactions: expectedTransactionsUI,
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => mockWatchTransactions.execute(
            const WatchTransactionsParams(limit: 10),
            traceId: traceId,
          ),
        ).called(1);
        verify(
          () => mockWatchWallets.execute(
            const WatchWalletsParams(),
            traceId: traceId,
          ),
        ).called(1);
        verify(
          () => mockWatchIncomeCategories.execute(
            const WatchIncomeCategoriesParams(),
            traceId: traceId,
          ),
        ).called(1);
        verify(
          () => mockWatchExpenseCategories.execute(
            const WatchExpenseCategoriesParams(),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'calls correct TransactionRepository.watch '
      'when wallet filter is provided',
      build: buildBloc,
      act: (bloc) => bloc.add(
        HomeEvent.transactionsSubscriptionRequested(wallet: wallets.first),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <HomeState>[
        HomeState(
          transactionsData: const HomeTransactionsUIModel(
            status: HomeUIStatus.loading,
          ),
        ),
        HomeState(
          transactionsData: HomeTransactionsUIModel(
            status: HomeUIStatus.loaded,
            transactions: expectedTransactionsUI,
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => mockWatchTransactions.execute(
            WatchTransactionsParams(
              wallet: wallets.first,
              limit: 10,
            ),
            traceId: traceId,
          ),
        ).called(1);
        verify(
          () => mockWatchWallets.execute(
            const WatchWalletsParams(),
            traceId: traceId,
          ),
        ).called(1);
        verify(
          () => mockWatchIncomeCategories.execute(
            const WatchIncomeCategoriesParams(),
            traceId: traceId,
          ),
        ).called(1);
        verify(
          () => mockWatchExpenseCategories.execute(
            const WatchExpenseCategoriesParams(),
            traceId: traceId,
          ),
        ).called(1);
      },
    );


    blocTest<HomeBloc, HomeState>(
      'uses debounce event transformer',
      build: buildBloc,
      act: (bloc) async {
        for (var i = 0; i < 5; i++) {
          bloc.add(
            const HomeEvent.transactionsSubscriptionRequested(),
          );
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
      },
      wait: kDefaultDebounceDuration,
      expect: () => <HomeState>[
        HomeState(
          transactionsData: const HomeTransactionsUIModel(
            status: HomeUIStatus.loading,
          ),
        ),
        HomeState(
          transactionsData: HomeTransactionsUIModel(
            status: HomeUIStatus.loaded,
            transactions: expectedTransactionsUI,
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => mockWatchTransactions.execute(
            const WatchTransactionsParams(limit: 10),
            traceId: traceId,
          ),
        ).called(1);
        verify(
          () => mockWatchWallets.execute(
            const WatchWalletsParams(),
            traceId: traceId,
          ),
        ).called(1);
        verify(
          () => mockWatchIncomeCategories.execute(
            const WatchIncomeCategoriesParams(),
            traceId: traceId,
          ),
        ).called(1);
        verify(
          () => mockWatchExpenseCategories.execute(
            const WatchExpenseCategoriesParams(),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'skips transactions when related wallet or category is not found',

      setUp: () {
        final orphanedIncome = Transaction.income(
          id: 'tr-orphan-income',
          walletId: 'unknown-wallet',
          incomeCategoryId: incomeCategory.id,
          amount: Decimal.fromInt(100),
          date: date,
        );
        final orphanedIncomeCat = Transaction.income(
          id: 'tr-orphan-inc-cat',
          walletId: wallets[0].id,
          incomeCategoryId: 'unknown-inc-cat',
          amount: Decimal.fromInt(100),
          date: date,
        );
        final orphanedExpense = Transaction.expense(
          id: 'tr-orphan-expense',
          walletId: 'unknown-wallet',
          expenseCategoryId: expenseCategory.id,
          amount: Decimal.fromInt(100),
          date: date,
        );
        final orphanedExpenseCat = Transaction.expense(
          id: 'tr-orphan-exp-cat',
          walletId: wallets[0].id,
          expenseCategoryId: 'unknown-exp-cat',
          amount: Decimal.fromInt(100),
          date: date,
        );
        final orphanedTransferSource = Transaction.transfer(
          id: 'tr-orphan-transfer-src',
          sourceWalletId: 'unknown-wallet',
          destinationWalletId: wallets[1].id,
          amount: Decimal.fromInt(100),
          fee: Decimal.zero,
          date: date,
        );
        final orphanedTransferDest = Transaction.transfer(
          id: 'tr-orphan-transfer-dst',
          sourceWalletId: wallets[0].id,
          destinationWalletId: 'unknown-wallet',
          amount: Decimal.fromInt(100),
          fee: Decimal.zero,
          date: date,
        );

        when(
          () => mockWatchTransactions.execute(
            const WatchTransactionsParams(limit: 10),
            traceId: traceId,
          ),
        ).thenAnswer(
          (_) => Stream.value(
            AppResult.success([
              orphanedIncome,
              orphanedIncomeCat,
              orphanedExpense,
              orphanedExpenseCat,
              orphanedTransferSource,
              orphanedTransferDest,
              incomeTransaction,
            ]),
          ),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const HomeEvent.transactionsSubscriptionRequested(),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <HomeState>[
        HomeState(
          transactionsData: const HomeTransactionsUIModel(
            status: HomeUIStatus.loading,
          ),
        ),
        HomeState(
          transactionsData: HomeTransactionsUIModel(
            status: HomeUIStatus.loaded,
            transactions: [expectedTransactionsUI.first],
          ),
        ),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'emits [loading, failure] '
      'when watchWallets emits failure',
      setUp: () {
        when(
          () => mockWatchWallets.execute(
            any<WatchWalletsParams>(),
            traceId: traceId,
          ),
        ).thenAnswer(
          (_) => Stream.value(
            AppResult<List<Wallet>>.failure(AppException.test()),
          ),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const HomeEvent.transactionsSubscriptionRequested(),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <HomeState>[
        HomeState(
          transactionsData: const HomeTransactionsUIModel(
            status: HomeUIStatus.loading,
          ),
        ),
        HomeState(
          transactionsData: HomeTransactionsUIModel(
            status: HomeUIStatus.failure,
            exception: AppException.test(),
          ),
        ),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'emits [loading, failure] '
      'when watchIncomeCategories emits failure',
      setUp: () {
        when(
          () => mockWatchIncomeCategories.execute(
            any<WatchIncomeCategoriesParams>(),
            traceId: traceId,
          ),
        ).thenAnswer(
          (_) => Stream.value(
            AppResult<List<IncomeCategory>>.failure(AppException.test()),
          ),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const HomeEvent.transactionsSubscriptionRequested(),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <HomeState>[
        HomeState(
          transactionsData: const HomeTransactionsUIModel(
            status: HomeUIStatus.loading,
          ),
        ),
        HomeState(
          transactionsData: HomeTransactionsUIModel(
            status: HomeUIStatus.failure,
            exception: AppException.test(),
          ),
        ),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'emits [loading, failure] '
      'when watchExpenseCategories emits failure',
      setUp: () {
        when(
          () => mockWatchExpenseCategories.execute(
            any<WatchExpenseCategoriesParams>(),
            traceId: traceId,
          ),
        ).thenAnswer(
          (_) => Stream.value(
            AppResult<List<ExpenseCategory>>.failure(AppException.test()),
          ),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const HomeEvent.transactionsSubscriptionRequested(),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <HomeState>[
        HomeState(
          transactionsData: const HomeTransactionsUIModel(
            status: HomeUIStatus.loading,
          ),
        ),
        HomeState(
          transactionsData: HomeTransactionsUIModel(
            status: HomeUIStatus.failure,
            exception: AppException.test(),
          ),
        ),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'emits [loading, failure] '
      'when watchTransactions emits failure',
      setUp: () {
        when(
          () => mockWatchTransactions.execute(
            const WatchTransactionsParams(limit: 10),
            traceId: traceId,
          ),
        ).thenAnswer(
          (_) => Stream.value(
            AppResult<List<Transaction>>.failure(AppException.test()),
          ),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const HomeEvent.transactionsSubscriptionRequested(),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <HomeState>[
        HomeState(
          transactionsData: const HomeTransactionsUIModel(
            status: HomeUIStatus.loading,
          ),
        ),
        HomeState(
          transactionsData: HomeTransactionsUIModel(
            status: HomeUIStatus.failure,
            exception: AppException.test(),
          ),
        ),
      ],
    );
  });
}
