import 'package:bloc_test/bloc_test.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/use_cases/journal/watch_current_balance.dart';
import 'package:journexa_app/domain/use_cases/wallet/delete_wallet.dart';
import 'package:journexa_app/domain/use_cases/wallet/update_wallet.dart';
import 'package:journexa_app/domain/use_cases/wallet/watch_wallets.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';
import 'package:journexa_app/ui/shared/event_transform/event_transform.dart';
import 'package:journexa_app/ui/wallets/bloc/wallets_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockWatchWalletsUseCase extends Mock implements WatchWalletsUseCase {}

class MockWatchCurrentBalanceUseCase extends Mock
    implements WatchCurrentBalanceUseCase {}

class MockDeleteWalletUseCase extends Mock implements DeleteWalletUseCase {}

class MockUpdateWalletUseCase extends Mock implements UpdateWalletUseCase {}

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
    return WalletUIModel(
      wallet: wallets[idx],
      balance: Decimal.fromInt(idx * 1000),
    );
  });
  final updatedFirstWallet = wallets.first.copyWith(
    name: 'new name',
    account: wallets.first.account.copyWith(
      name: 'new name',
    ),
  );

  late MockWatchWalletsUseCase mockWatchWallets;
  late MockWatchCurrentBalanceUseCase mockWatchCurrentBalance;
  late MockDeleteWalletUseCase mockDeleteWalletUseCase;
  late MockUpdateWalletUseCase mockUpdateWalletUseCase;
  late MockUidGenerator mockUidGenerator;

  setUpAll(() {
    registerFallbackValue(
      const WatchWalletsParams(),
    );
    registerFallbackValue(
      DeleteWalletParams(wallet: wallets.first),
    );
    registerFallbackValue(
      UpdateWalletParams(
        wallet: wallets.first,
        name: 'new name',
      ),
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

    mockDeleteWalletUseCase = MockDeleteWalletUseCase();
    when(
      () => mockDeleteWalletUseCase.execute(
        any<DeleteWalletParams>(),
        traceId: traceId,
      ),
    ).thenAnswer((_) async => const AppResult.success(null));

    mockUpdateWalletUseCase = MockUpdateWalletUseCase();
    when(
      () => mockUpdateWalletUseCase.execute(
        any<UpdateWalletParams>(),
        traceId: traceId,
      ),
    ).thenAnswer(
      (_) async => AppResult.success(updatedFirstWallet),
    );
  });

  WalletsBloc buildBloc() {
    return WalletsBloc(
      watchWallets: mockWatchWallets,
      watchAccountBalances: mockWatchCurrentBalance,
      deleteWallet: mockDeleteWalletUseCase,
      updateWallet: mockUpdateWalletUseCase,
    )..customGenerator = mockUidGenerator;
  }

  test('has initial state of WalletsState.initial', () {
    final bloc = buildBloc();
    expect(bloc.state, const WalletsState());
  });

  group('subscriptionRequested', () {
    blocTest<WalletsBloc, WalletsState>(
      'emits [loading, loaded] '
      'with correct wallet balances '
      'when all watch use cases return success',
      build: buildBloc,
      act: (bloc) => bloc.add(
        const WalletsEvent.subscriptionRequested(),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <WalletsState>[
        const WalletsState(status: WalletsUIStatus.loading),
        WalletsState(
          status: WalletsUIStatus.loaded,
          wallets: walletsWithState,
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

    blocTest<WalletsBloc, WalletsState>(
      'emits [loading, loaded] '
      'with correct wallet balances and params '
      'when all watch use cases return success',
      build: buildBloc,
      act: (bloc) => bloc.add(
        const WalletsEvent.subscriptionRequested(query: 'query'),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <WalletsState>[
        const WalletsState(status: WalletsUIStatus.loading),
        WalletsState(
          status: WalletsUIStatus.loaded,
          wallets: walletsWithState,
        ),
      ],
      verify: (_) {
        verify(
          () => mockWatchWallets.execute(
            const WatchWalletsParams(query: 'query'),
            traceId: traceId,
          ),
        ).called(1);
        verify(
          () => mockWatchCurrentBalance.execute(traceId: traceId),
        ).called(1);
      },
    );

    blocTest<WalletsBloc, WalletsState>(
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
        const WalletsEvent.subscriptionRequested(),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <WalletsState>[
        const WalletsState(status: WalletsUIStatus.loading),
        WalletsState(
          status: WalletsUIStatus.loaded,
          wallets: wallets
              .map((w) => WalletUIModel(wallet: w, balance: Decimal.zero))
              .toList(),
        ),
      ],
    );

    blocTest<WalletsBloc, WalletsState>(
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
        const WalletsEvent.subscriptionRequested(),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <WalletsState>[
        const WalletsState(status: WalletsUIStatus.loading),
        WalletsState(
          status: WalletsUIStatus.failure,
          exception: AppException.test(),
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

    blocTest<WalletsBloc, WalletsState>(
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
        const WalletsEvent.subscriptionRequested(),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <WalletsState>[
        const WalletsState(status: WalletsUIStatus.loading),
        WalletsState(
          status: WalletsUIStatus.failure,
          exception: AppException.test(),
        ),
      ],
      verify: (_) {
        verify(
          () => mockWatchCurrentBalance.execute(traceId: traceId),
        ).called(1);
      },
    );
  });

  group('delete', () {
    blocTest<WalletsBloc, WalletsState>(
      'emits [new wallets, loaded with notice] '
      'when deleteWalletUseCase returns success',
      seed: () {
        return WalletsState(
          status: WalletsUIStatus.loaded,
          wallets: walletsWithState,
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        WalletsEvent.delete(wallets.first),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <WalletsState>[
        WalletsState(
          status: WalletsUIStatus.loaded,
          wallets: walletsWithState.map((it) {
            final isDeleting = it.wallet.id == wallets.first.id;
            if (!isDeleting) return it;
            return it.copyWith(status: WalletUIStatus.deleting);
          }).toList(),
        ),
        WalletsState(
          status: WalletsUIStatus.loaded,
          wallets: walletsWithState.map((it) {
            final isDeleting = it.wallet.id == wallets.first.id;
            if (!isDeleting) return it;
            return it.copyWith(status: WalletUIStatus.deleting);
          }).toList(),
          notice: WalletUINotice.recentlyDeleted(wallet: wallets.first),
        ),
      ],
      verify: (_) {
        verify(
          () => mockDeleteWalletUseCase.execute(
            DeleteWalletParams(wallet: wallets.first),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<WalletsBloc, WalletsState>(
      'emits [new wallets, '
      'new idle wallets and failed notice] '
      'when deleteWalletUseCase returns failure',
      setUp: () {
        when(
          () => mockDeleteWalletUseCase.execute(
            DeleteWalletParams(wallet: wallets.first),
            traceId: traceId,
          ),
        ).thenAnswer((_) async => AppResult<Null>.failure(AppException.test()));
      },
      seed: () {
        return WalletsState(
          status: WalletsUIStatus.loaded,
          wallets: walletsWithState,
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        WalletsEvent.delete(wallets.first),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <WalletsState>[
        WalletsState(
          status: WalletsUIStatus.loaded,
          wallets: walletsWithState.map((it) {
            final isDeleting = it.wallet.id == wallets.first.id;
            if (!isDeleting) return it;
            return it.copyWith(status: WalletUIStatus.deleting);
          }).toList(),
        ),
        WalletsState(
          status: WalletsUIStatus.loaded,
          wallets: walletsWithState,
          notice: WalletUINotice.deleteFailed(
            wallet: wallets.first,
            exception: AppException.test(),
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => mockDeleteWalletUseCase.execute(
            DeleteWalletParams(
              wallet: wallets.first,
            ),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<WalletsBloc, WalletsState>(
      'do nothing when wallet not found on wallets',
      seed: () {
        return const WalletsState(
          status: WalletsUIStatus.loaded,
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        WalletsEvent.delete(wallets.first),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <WalletsState>[],
      verify: (_) {
        verifyZeroInteractions(mockDeleteWalletUseCase);
      },
    );
  });

  group('update', () {
    blocTest<WalletsBloc, WalletsState>(
      'emits [new updating wallets, loaded with updated notice] '
      'when updateWalletUseCase returns success',
      seed: () {
        return WalletsState(
          status: WalletsUIStatus.loaded,
          wallets: walletsWithState,
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        WalletsEvent.update(
          wallets.first,
          name: updatedFirstWallet.name,
        ),
      ),
      expect: () => <WalletsState>[
        WalletsState(
          status: WalletsUIStatus.loaded,
          wallets: walletsWithState.map((it) {
            final isUpdating = it.wallet.id == wallets.first.id;
            if (!isUpdating) return it;
            return it.copyWith(status: WalletUIStatus.updating);
          }).toList(),
        ),
        WalletsState(
          status: WalletsUIStatus.loaded,
          wallets: walletsWithState.map((it) {
            final isUpdating = it.wallet.id == wallets.first.id;
            if (!isUpdating) return it;
            return it.copyWith(status: WalletUIStatus.updating);
          }).toList(),
          notice: WalletUINotice.recentlyUpdated(
            from: wallets.first,
            to: updatedFirstWallet,
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => mockUpdateWalletUseCase.execute(
            UpdateWalletParams(
              wallet: wallets.first,
              name: updatedFirstWallet.name,
            ),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<WalletsBloc, WalletsState>(
      'emits [new wallets, '
      'new wallets with idle status and updateFailure notice] '
      'when updateWalletUseCase returns failure',
      setUp: () {
        when(
          () => mockUpdateWalletUseCase.execute(
            UpdateWalletParams(
              wallet: wallets.first,
              name: updatedFirstWallet.name,
            ),
            traceId: traceId,
          ),
        ).thenAnswer(
          (_) async => AppResult<Wallet>.failure(AppException.test()),
        );
      },
      seed: () {
        return WalletsState(
          status: WalletsUIStatus.loaded,
          wallets: walletsWithState,
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        WalletsEvent.update(
          wallets.first,
          name: updatedFirstWallet.name,
        ),
      ),
      expect: () => <WalletsState>[
        WalletsState(
          status: WalletsUIStatus.loaded,
          wallets: walletsWithState.map((it) {
            final isUpdating = it.wallet.id == wallets.first.id;
            if (!isUpdating) return it;
            return it.copyWith(status: WalletUIStatus.updating);
          }).toList(),
        ),
        WalletsState(
          status: WalletsUIStatus.loaded,
          wallets: walletsWithState,
          notice: WalletUINotice.updateFailed(
            wallet: wallets.first,
            exception: AppException.test(),
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => mockUpdateWalletUseCase.execute(
            UpdateWalletParams(
              wallet: wallets.first,
              name: updatedFirstWallet.name,
            ),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<WalletsBloc, WalletsState>(
      'do nothing when wallet not found on wallets',
      seed: () {
        return const WalletsState(
          status: WalletsUIStatus.loaded,
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        WalletsEvent.update(
          wallets.first,
          name: updatedFirstWallet.name,
        ),
      ),
      expect: () => <WalletsState>[],
      verify: (_) {
        verifyZeroInteractions(mockUpdateWalletUseCase);
      },
    );
  });
}
