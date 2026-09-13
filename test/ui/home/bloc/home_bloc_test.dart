import 'package:bloc_test/bloc_test.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/use_cases/journal/watch_current_balance.dart';
import 'package:journexa_app/domain/use_cases/journal/watch_total_mtd_expense.dart';
import 'package:journexa_app/domain/use_cases/journal/watch_total_mtd_income.dart';
import 'package:journexa_app/domain/use_cases/wallet/watch_wallets.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';
import 'package:journexa_app/ui/home/bloc/home_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockWatchWalletsUseCase extends Mock implements WatchWalletsUseCase {}

class MockWatchCurrentBalanceUseCase extends Mock
    implements WatchCurrentBalanceUseCase {}

class MockUidGenerator extends Mock implements UidGenerator {}

class MockWatchTotalMTDIncomeUseCase extends Mock
    implements WatchTotalMTDIncomeUseCase {}

class MockWatchTotalMTDExpenseUseCase extends Mock
    implements WatchTotalMTDExpenseUseCase {}

void main() {
  const traceId = 'traceId';
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

  late WatchWalletsUseCase mockWatchWallets;
  late WatchCurrentBalanceUseCase mockWatchCurrentBalance;
  late UidGenerator mockUidGenerator;
  late WatchTotalMTDIncomeUseCase mockWatchTotalMTDIncome;
  late WatchTotalMTDExpenseUseCase mockWatchTotalMTDExpense;

  setUpAll(() {
    registerFallbackValue(
      const WatchWalletsParams(),
    );
    registerFallbackValue(watchMTDIncomeParams);
    registerFallbackValue(watchMTDExpenseParams);
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
        watchMTDIncomeParams,
        traceId: traceId,
      ),
    ).thenAnswer((_) => Stream.value(AppResult.success(totalMTDIncome)));

    mockWatchTotalMTDExpense = MockWatchTotalMTDExpenseUseCase();
    when(
      () => mockWatchTotalMTDExpense.execute(
        watchMTDExpenseParams,
        traceId: traceId,
      ),
    ).thenAnswer((_) => Stream.value(AppResult.success(totalMTDExpense)));
  });

  HomeBloc buildBloc() {
    return HomeBloc(
      watchWallets: mockWatchWallets,
      watchAccountBalances: mockWatchCurrentBalance,
      watchTotalMTDIncome: mockWatchTotalMTDIncome,
      watchTotalMTDExpense: mockWatchTotalMTDExpense,
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
}
