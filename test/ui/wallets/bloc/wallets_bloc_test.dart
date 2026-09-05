import 'package:bloc_test/bloc_test.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/use_cases/wallet/delete_wallet.dart';
import 'package:journexa_app/domain/use_cases/wallet/update_wallet.dart';
import 'package:journexa_app/domain/use_cases/wallet/watch_wallets.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';
import 'package:journexa_app/ui/shared/event_transform/event_transform.dart';
import 'package:journexa_app/ui/wallets/bloc/wallets_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockWatchWallets extends Mock implements WatchWalletsUseCase {}

class MockUidGenerator extends Mock implements UidGenerator {}

class MockDeleteWalletUseCase extends Mock implements DeleteWalletUseCase {}

class MockUpdateWalletUseCase extends Mock implements UpdateWalletUseCase {}

void main() {
  const traceId = 'traceId';
  final assetParent = SystemDefinedAccount.rootAsset;
  final wallets = List.generate(5, (idx) {
    return WalletWithBalance(
      wallet: Wallet(
        id: '$idx',
        name: 'asset $idx',
        account: Account(
          code: '10.000${idx + 1}',
          name: 'asset $idx',
          type: AccountType.asset,
          parent: assetParent,
        ),
      ),
      balance: Decimal.fromInt(idx * 1000),
    );
  });
  final walletsWithState = wallets.map(
    (it) {
      return WalletWithBalanceUIModel(
        walletWithBalance: it,
      );
    },
  ).toList();
  final updatedFirstWallet = wallets.first.wallet.copyWith(
    name: 'new name',
    account: wallets.first.wallet.account.copyWith(
      name: 'new name',
    ),
  );

  late WatchWalletsUseCase mockWatchWallets;
  late UidGenerator mockUidGenerator;
  late DeleteWalletUseCase mockDeleteWalletUseCase;
  late MockUpdateWalletUseCase mockUpdateWalletUseCase;

  setUpAll(() {
    registerFallbackValue(
      const WatchWalletsParams(),
    );
    registerFallbackValue(
      DeleteWalletParams(wallet: wallets.first.wallet),
    );
    registerFallbackValue(
      UpdateWalletParams(
        wallet: wallets.first.wallet,
        name: 'new name',
      ),
    );
  });

  setUp(() {
    mockUidGenerator = MockUidGenerator();
    when(mockUidGenerator.generateUid).thenReturn(traceId);

    mockWatchWallets = MockWatchWallets();
    when(
      () => mockWatchWallets.execute(
        any<WatchWalletsParams>(),
        traceId: traceId,
      ),
    ).thenAnswer(
      (_) => Stream.value(AppResult.success(wallets)),
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
      'when watchWalletsUseCase returns success',
      build: buildBloc,
      act: (bloc) => bloc.add(
        const WalletsEvent.subscriptionRequested(),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <WalletsState>[
        const WalletsState(status: WalletsUIStatus.loading),
        WalletsState(
          status: WalletsUIStatus.loaded,
          walletWithBalances: walletsWithState,
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
      'emits [loading, loaded] '
      'with correct wallet balances and params '
      'when watchWalletsUseCase returns success',
      build: buildBloc,
      act: (bloc) => bloc.add(
        const WalletsEvent.subscriptionRequested(query: 'query'),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <WalletsState>[
        const WalletsState(status: WalletsUIStatus.loading),
        WalletsState(
          status: WalletsUIStatus.loaded,
          walletWithBalances: walletsWithState,
        ),
      ],
      verify: (_) {
        verify(
          () => mockWatchWallets.execute(
            const WatchWalletsParams(query: 'query'),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<WalletsBloc, WalletsState>(
      'emits [loading, failure] '
      'when watchWalletsUseCase emits failure',
      setUp: () {
        when(
          () => mockWatchWallets.execute(
            const WatchWalletsParams(),
            traceId: traceId,
          ),
        ).thenAnswer(
          (_) => Stream.value(
            AppResult<List<WalletWithBalance>>.failure(AppException.test()),
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
  });

  group('delete', () {
    blocTest<WalletsBloc, WalletsState>(
      'emits [new walletWithBalances, loaded with notice] '
      'when deleteWalletUseCase returns success',
      seed: () {
        return WalletsState(
          status: WalletsUIStatus.loaded,
          walletWithBalances: walletsWithState,
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        WalletsEvent.delete(wallets.first.wallet),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <WalletsState>[
        WalletsState(
          status: WalletsUIStatus.loaded,
          walletWithBalances: walletsWithState.map((it) {
            final isDeleting =
                it.walletWithBalance.wallet.id == wallets.first.wallet.id;
            if (!isDeleting) return it;
            return it.copyWith(status: WalletUIStatus.deleting);
          }).toList(),
        ),
        WalletsState(
          status: WalletsUIStatus.loaded,
          walletWithBalances: walletsWithState.map((it) {
            final isDeleting =
                it.walletWithBalance.wallet.id == wallets.first.wallet.id;
            if (!isDeleting) return it;
            return it.copyWith(status: WalletUIStatus.deleting);
          }).toList(),
          notice: WalletUINotice.recentlyDeleted(wallet: wallets.first.wallet),
        ),
      ],
      verify: (_) {
        verify(
          () => mockDeleteWalletUseCase.execute(
            DeleteWalletParams(wallet: wallets.first.wallet),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<WalletsBloc, WalletsState>(
      'emits [new walletWithBalances, '
      'new idle walletWithBalances and failed notice] '
      'when deleteWalletUseCase returns failure',
      setUp: () {
        when(
          () => mockDeleteWalletUseCase.execute(
            DeleteWalletParams(wallet: wallets.first.wallet),
            traceId: traceId,
          ),
        ).thenAnswer((_) async => AppResult<Null>.failure(AppException.test()));
      },
      seed: () {
        return WalletsState(
          status: WalletsUIStatus.loaded,
          walletWithBalances: walletsWithState,
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        WalletsEvent.delete(wallets.first.wallet),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <WalletsState>[
        WalletsState(
          status: WalletsUIStatus.loaded,
          walletWithBalances: walletsWithState.map((it) {
            final isDeleting =
                it.walletWithBalance.wallet.id == wallets.first.wallet.id;
            if (!isDeleting) return it;
            return it.copyWith(status: WalletUIStatus.deleting);
          }).toList(),
        ),
        WalletsState(
          status: WalletsUIStatus.loaded,
          walletWithBalances: walletsWithState,
          notice: WalletUINotice.deleteFailed(
            wallet: wallets.first.wallet,
            exception: AppException.test(),
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => mockDeleteWalletUseCase.execute(
            DeleteWalletParams(
              wallet: wallets.first.wallet,
            ),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<WalletsBloc, WalletsState>(
      'do nothing when wallet not found on walletWithBalances',
      seed: () {
        return const WalletsState(
          status: WalletsUIStatus.loaded,
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        WalletsEvent.delete(wallets.first.wallet),
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
      'emits [new updating walletWithBalances, loaded with updated notice] '
      'when updateWalletUseCase returns success',
      seed: () {
        return WalletsState(
          status: WalletsUIStatus.loaded,
          walletWithBalances: walletsWithState,
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        WalletsEvent.update(
          wallets.first.wallet,
          name: updatedFirstWallet.name,
        ),
      ),
      expect: () => <WalletsState>[
        WalletsState(
          status: WalletsUIStatus.loaded,
          walletWithBalances: walletsWithState.map((it) {
            final isUpdating =
                it.walletWithBalance.wallet.id == wallets.first.wallet.id;
            if (!isUpdating) return it;
            return it.copyWith(status: WalletUIStatus.updating);
          }).toList(),
        ),
        WalletsState(
          status: WalletsUIStatus.loaded,
          walletWithBalances: walletsWithState.map((it) {
            final isUpdating =
                it.walletWithBalance.wallet.id == wallets.first.wallet.id;
            if (!isUpdating) return it;
            return it.copyWith(status: WalletUIStatus.updating);
          }).toList(),
          notice: WalletUINotice.recentlyUpdated(
            from: wallets.first.wallet,
            to: updatedFirstWallet,
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => mockUpdateWalletUseCase.execute(
            UpdateWalletParams(
              wallet: wallets.first.wallet,
              name: updatedFirstWallet.name,
            ),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<WalletsBloc, WalletsState>(
      'emits [new walletWithBalances, '
      'new walletWithBalances with idle status and updateFailure notice] '
      'when updateWalletUseCase returns failure',
      setUp: () {
        when(
          () => mockUpdateWalletUseCase.execute(
            UpdateWalletParams(
              wallet: wallets.first.wallet,
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
          walletWithBalances: walletsWithState,
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        WalletsEvent.update(
          wallets.first.wallet,
          name: updatedFirstWallet.name,
        ),
      ),
      expect: () => <WalletsState>[
        WalletsState(
          status: WalletsUIStatus.loaded,
          walletWithBalances: walletsWithState.map((it) {
            final isUpdating =
                it.walletWithBalance.wallet.id == wallets.first.wallet.id;
            if (!isUpdating) return it;
            return it.copyWith(status: WalletUIStatus.updating);
          }).toList(),
        ),
        WalletsState(
          status: WalletsUIStatus.loaded,
          walletWithBalances: walletsWithState,
          notice: WalletUINotice.updateFailed(
            wallet: wallets.first.wallet,
            exception: AppException.test(),
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => mockUpdateWalletUseCase.execute(
            UpdateWalletParams(
              wallet: wallets.first.wallet,
              name: updatedFirstWallet.name,
            ),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<WalletsBloc, WalletsState>(
      'do nothing when wallet not found on walletWithBalances',
      seed: () {
        return const WalletsState(
          status: WalletsUIStatus.loaded,
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        WalletsEvent.update(
          wallets.first.wallet,
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
