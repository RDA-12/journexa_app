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
import 'package:journexa_app/domain/use_cases/transaction/watch_transactions.dart';
import 'package:journexa_app/domain/use_cases/wallet/watch_wallets.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';
import 'package:journexa_app/ui/shared/event_transform/event_transform.dart';
import 'package:journexa_app/ui/transactions/bloc/transactions_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockWatchTransactionsUseCase extends Mock
    implements WatchTransactionsUseCase {}

class MockWatchWalletsUseCase extends Mock implements WatchWalletsUseCase {}

class MockWatchIncomeCategoriesUseCase extends Mock
    implements WatchIncomeCategoriesUseCase {}

class MockWatchExpenseCategoriesUseCase extends Mock
    implements WatchExpenseCategoriesUseCase {}

class MockUidGenerator extends Mock implements UidGenerator {}

void main() {
  const traceId = 'traceId';
  final date = DateTime(2026);

  final wallet1 = Wallet(
    id: 'wallet-1',
    name: 'Wallet 1',
    account: Account.sub(
      parent: SystemDefinedAccount.walletParent,
      name: 'Wallet 1',
      currentChildrenCount: 0,
    ),
  );

  final wallet2 = Wallet(
    id: 'wallet-2',
    name: 'Wallet 2',
    account: Account.sub(
      parent: SystemDefinedAccount.walletParent,
      name: 'Wallet 2',
      currentChildrenCount: 1,
    ),
  );

  final wallets = [wallet1, wallet2];

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
    walletId: wallet1.id,
    incomeCategoryId: incomeCategory.id,
    amount: Decimal.fromInt(500),
    date: date,
    notes: 'Income note',
  );

  final expenseTransaction = ExpenseTransaction(
    id: 'tr-expense-1',
    walletId: wallet1.id,
    expenseCategoryId: expenseCategory.id,
    amount: Decimal.fromInt(200),
    date: date,
    notes: 'Expense note',
  );

  final transferTransaction = TransferTransaction(
    id: 'tr-transfer-1',
    sourceWalletId: wallet1.id,
    destinationWalletId: wallet2.id,
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
      wallet: wallet1,
      category: incomeCategory,
      amount: incomeTransaction.amount,
      date: incomeTransaction.date,
      notes: incomeTransaction.notes,
    ),
    TransactionUIModel.expense(
      id: expenseTransaction.id,
      wallet: wallet1,
      category: expenseCategory,
      amount: expenseTransaction.amount,
      date: expenseTransaction.date,
      notes: expenseTransaction.notes,
    ),
    TransactionUIModel.transfer(
      id: transferTransaction.id,
      sourceWallet: wallet1,
      destinationWallet: wallet2,
      amount: transferTransaction.amount,
      fee: transferTransaction.fee,
      date: transferTransaction.date,
      notes: transferTransaction.notes,
    ),
  ];

  late MockWatchTransactionsUseCase mockWatchTransactions;
  late MockWatchWalletsUseCase mockWatchWallets;
  late MockWatchIncomeCategoriesUseCase mockWatchIncomeCategories;
  late MockWatchExpenseCategoriesUseCase mockWatchExpenseCategories;
  late MockUidGenerator mockUidGenerator;

  setUpAll(() {
    registerFallbackValue(const WatchWalletsParams());
    registerFallbackValue(const WatchIncomeCategoriesParams());
    registerFallbackValue(const WatchExpenseCategoriesParams());
  });

  setUp(() {
    mockUidGenerator = MockUidGenerator();
    when(mockUidGenerator.generateUid).thenReturn(traceId);

    mockWatchTransactions = MockWatchTransactionsUseCase();
    when(
      () => mockWatchTransactions.execute(traceId: traceId),
    ).thenAnswer((_) => Stream.value(AppResult.success(transactions)));

    mockWatchWallets = MockWatchWalletsUseCase();
    when(
      () => mockWatchWallets.execute(
        any<WatchWalletsParams>(),
        traceId: traceId,
      ),
    ).thenAnswer((_) => Stream.value(AppResult.success(wallets)));

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

  TransactionsBloc buildBloc() {
    return TransactionsBloc(
      watchTransactions: mockWatchTransactions,
      watchWallets: mockWatchWallets,
      watchIncomeCategories: mockWatchIncomeCategories,
      watchExpenseCategories: mockWatchExpenseCategories,
    )..customGenerator = mockUidGenerator;
  }

  test('has initial state of TransactionsState.initial', () {
    final bloc = buildBloc();
    expect(bloc.state, const TransactionsState.initial());
  });

  group('subscriptionRequested', () {
    blocTest<TransactionsBloc, TransactionsState>(
      'emits [loading, loaded] '
      'with correct mapped transactions '
      'when all watch use cases return success',
      build: buildBloc,
      act: (bloc) => bloc.add(
        const TransactionsEvent.subscriptionRequested(),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <TransactionsState>[
        const TransactionsState.loading(),
        TransactionsState.loaded(expectedTransactionsUI),
      ],
      verify: (_) {
        verify(
          () => mockWatchTransactions.execute(traceId: traceId),
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

    blocTest<TransactionsBloc, TransactionsState>(
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
          walletId: wallet1.id,
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
          walletId: wallet1.id,
          expenseCategoryId: 'unknown-exp-cat',
          amount: Decimal.fromInt(100),
          date: date,
        );
        final orphanedTransferSource = Transaction.transfer(
          id: 'tr-orphan-transfer-src',
          sourceWalletId: 'unknown-wallet',
          destinationWalletId: wallet2.id,
          amount: Decimal.fromInt(100),
          fee: Decimal.zero,
          date: date,
        );
        final orphanedTransferDest = Transaction.transfer(
          id: 'tr-orphan-transfer-dst',
          sourceWalletId: wallet1.id,
          destinationWalletId: 'unknown-wallet',
          amount: Decimal.fromInt(100),
          fee: Decimal.zero,
          date: date,
        );

        when(
          () => mockWatchTransactions.execute(traceId: traceId),
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
        const TransactionsEvent.subscriptionRequested(),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <TransactionsState>[
        const TransactionsState.loading(),
        TransactionsState.loaded([expectedTransactionsUI.first]),
      ],
    );

    blocTest<TransactionsBloc, TransactionsState>(
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
        const TransactionsEvent.subscriptionRequested(),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <TransactionsState>[
        const TransactionsState.loading(),
        TransactionsState.failure(AppException.test()),
      ],
    );

    blocTest<TransactionsBloc, TransactionsState>(
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
        const TransactionsEvent.subscriptionRequested(),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <TransactionsState>[
        const TransactionsState.loading(),
        TransactionsState.failure(AppException.test()),
      ],
    );

    blocTest<TransactionsBloc, TransactionsState>(
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
        const TransactionsEvent.subscriptionRequested(),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <TransactionsState>[
        const TransactionsState.loading(),
        TransactionsState.failure(AppException.test()),
      ],
    );

    blocTest<TransactionsBloc, TransactionsState>(
      'emits [loading, failure] '
      'when watchTransactions emits failure',
      setUp: () {
        when(
          () => mockWatchTransactions.execute(traceId: traceId),
        ).thenAnswer(
          (_) => Stream.value(
            AppResult<List<Transaction>>.failure(AppException.test()),
          ),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const TransactionsEvent.subscriptionRequested(),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <TransactionsState>[
        const TransactionsState.loading(),
        TransactionsState.failure(AppException.test()),
      ],
    );
  });
}
