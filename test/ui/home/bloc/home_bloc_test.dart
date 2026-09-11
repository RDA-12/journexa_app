import 'package:bloc_test/bloc_test.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/use_cases/journal/watch_current_balance.dart';
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

  late MockWatchWalletsUseCase mockWatchWallets;
  late MockWatchCurrentBalanceUseCase mockWatchCurrentBalance;
  late MockUidGenerator mockUidGenerator;

  setUpAll(() {
    registerFallbackValue(
      const WatchWalletsParams(),
    );
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
  });

  HomeBloc buildBloc() {
    return HomeBloc(
      watchWallets: mockWatchWallets,
      watchAccountBalances: mockWatchCurrentBalance,
    )..customGenerator = mockUidGenerator;
  }

  test('has initial state of HomeState()', () {
    final bloc = buildBloc();
    expect(bloc.state, const HomeState());
  });

  group('subscriptionsRequested', () {
    group('wallets', () {
      blocTest<HomeBloc, HomeState>(
        'emits [loading, loaded] '
        'with correct wallet balances '
        'when all watch use cases return success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          const HomeEvent.subscriptionsRequested(),
        ),
        expect: () => <HomeState>[
          const HomeState(
            wallets: HomeWalletsUIModel(
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
          const HomeEvent.subscriptionsRequested(),
        ),
        expect: () => <HomeState>[
          const HomeState(
            wallets: HomeWalletsUIModel(
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
          const HomeEvent.subscriptionsRequested(),
        ),
        expect: () => <HomeState>[
          const HomeState(
            wallets: HomeWalletsUIModel(
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
          const HomeEvent.subscriptionsRequested(),
        ),
        expect: () => <HomeState>[
          const HomeState(
            wallets: HomeWalletsUIModel(
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
}
