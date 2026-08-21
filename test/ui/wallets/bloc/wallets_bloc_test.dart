import 'package:bloc_test/bloc_test.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/use_cases/wallet/delete_wallet.dart';
import 'package:journexa_app/domain/use_cases/wallet/get_all_wallets.dart';
import 'package:journexa_app/domain/use_cases/wallet/update_wallet.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';
import 'package:journexa_app/ui/shared/event_transform/event_transform.dart';
import 'package:journexa_app/ui/wallets/bloc/wallets_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockGetAllWallets extends Mock implements GetAllWalletsUseCase {}

class MockUidGenerator extends Mock implements UidGenerator {}

class MockDeleteWalletUseCase extends Mock implements DeleteWalletUseCase {}

class MockUpdateWalletUseCase extends Mock implements UpdateWalletUseCase {}

void main() {
  const traceId = 'traceId';
  final assetParent = kSystemDefinedAccounts.firstWhere(
    (it) => it.code == '10.0000',
  );
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
      return WalletWithBalanceState(
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

  late GetAllWalletsUseCase mockGetAllWallets;
  late UidGenerator mockUidGenerator;
  late DeleteWalletUseCase mockDeleteWalletUseCase;
  late MockUpdateWalletUseCase mockUpdateWalletUseCase;

  setUpAll(() {
    registerFallbackValue(
      const GetAllWalletsParams(),
    );
    registerFallbackValue(
      DeleteWalletParams(wallet: wallets.first.wallet),
    );
    registerFallbackValue(
      UpdateWalletParams(wallet: wallets.first.wallet),
    );
  });

  setUp(() {
    mockUidGenerator = MockUidGenerator();
    when(mockUidGenerator.generateUid).thenReturn(traceId);

    mockGetAllWallets = MockGetAllWallets();
    when(
      () => mockGetAllWallets.execute(
        any<GetAllWalletsParams>(),
        traceId: traceId,
      ),
    ).thenAnswer(
      (_) async => AppResult.success(wallets),
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
      getAllWallets: mockGetAllWallets,
      deleteWallet: mockDeleteWalletUseCase,
      updateWallet: mockUpdateWalletUseCase,
    )..customGenerator = mockUidGenerator;
  }

  test('has initial state of WalletsState.initial', () {
    final bloc = buildBloc();
    expect(bloc.state, const WalletsState());
  });

  group('load', () {
    blocTest<WalletsBloc, WalletsState>(
      'emits [loading, loaded] '
      'with correct wallet balances '
      'when getAllWalletsUseCase returns success',
      build: buildBloc,
      act: (bloc) => bloc.add(const WalletsEvent.load()),
      expect: () => <WalletsState>[
        const WalletsState(status: WalletsStatus.loading),
        WalletsState(
          status: WalletsStatus.loaded,
          walletWithBalances: walletsWithState,
        ),
      ],
      verify: (_) {
        verify(
          () => mockGetAllWallets.execute(
            const GetAllWalletsParams(),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<WalletsBloc, WalletsState>(
      'emits [loading, failure] '
      'when getAllWalletsUseCase returns failure',
      setUp: () {
        when(
          () => mockGetAllWallets.execute(
            const GetAllWalletsParams(),
            traceId: traceId,
          ),
        ).thenAnswer(
          (_) async =>
              AppResult<List<WalletWithBalance>>.failure(AppException.test()),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const WalletsEvent.load()),
      expect: () => <WalletsState>[
        const WalletsState(status: WalletsStatus.loading),
        WalletsState(
          status: WalletsStatus.failure,
          exception: AppException.test(),
        ),
      ],
      verify: (_) {
        verify(
          () => mockGetAllWallets.execute(
            const GetAllWalletsParams(),
            traceId: traceId,
          ),
        ).called(1);
      },
    );
  });

  group('search', () {
    blocTest<WalletsBloc, WalletsState>(
      'only process last event within debounce time',
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const WalletsEvent.search(query: 'q'))
        ..add(const WalletsEvent.search(query: 'que'))
        ..add(const WalletsEvent.search(query: 'query')),
      wait: kDefaultDebounceDuration + const Duration(milliseconds: 1),
      expect: () => <WalletsState>[
        const WalletsState(status: WalletsStatus.loading),
        WalletsState(
          status: WalletsStatus.loaded,
          walletWithBalances: walletsWithState,
        ),
      ],
      verify: (_) {
        verify(
          () => mockGetAllWallets.execute(
            const GetAllWalletsParams(query: 'query'),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<WalletsBloc, WalletsState>(
      'emits [loading, loaded] '
      'with correct wallet balances '
      'when getAllWalletsUseCase returns success',
      build: buildBloc,
      act: (bloc) => bloc.add(const WalletsEvent.search(query: 'query')),
      wait: kDefaultDebounceDuration,
      expect: () => <WalletsState>[
        const WalletsState(status: WalletsStatus.loading),
        WalletsState(
          status: WalletsStatus.loaded,
          walletWithBalances: walletsWithState,
        ),
      ],
      verify: (_) {
        verify(
          () => mockGetAllWallets.execute(
            const GetAllWalletsParams(query: 'query'),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<WalletsBloc, WalletsState>(
      'emits [loading, failure] '
      'when getAllWalletsUseCase returns failure',
      setUp: () {
        when(
          () => mockGetAllWallets.execute(
            const GetAllWalletsParams(query: 'query'),
            traceId: traceId,
          ),
        ).thenAnswer(
          (_) async =>
              AppResult<List<WalletWithBalance>>.failure(AppException.test()),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const WalletsEvent.search(query: 'query')),
      wait: kDefaultDebounceDuration,
      expect: () => <WalletsState>[
        const WalletsState(status: WalletsStatus.loading),
        WalletsState(
          status: WalletsStatus.failure,
          exception: AppException.test(),
        ),
      ],
      verify: (_) {
        verify(
          () => mockGetAllWallets.execute(
            const GetAllWalletsParams(query: 'query'),
            traceId: traceId,
          ),
        ).called(1);
      },
    );
  });

  group('delete', () {
    final deletedWallet = wallets.first.wallet;

    blocTest<WalletsBloc, WalletsState>(
      'emits [new walletWithBalances, '
      'loaded new walletWithBalances with notice] '
      'when deleteWalletUseCase returns success',
      seed: () {
        return WalletsState(
          status: WalletsStatus.loaded,
          walletWithBalances: walletsWithState,
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        WalletsEvent.delete(deletedWallet),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <WalletsState>[
        WalletsState(
          status: WalletsStatus.loaded,
          walletWithBalances: walletsWithState.map((it) {
            final isDeleting =
                it.walletWithBalance.wallet.id == deletedWallet.id;
            if (!isDeleting) return it;
            return it.copyWith(status: WalletStatus.deleting);
          }).toList(),
        ),
        WalletsState(
          status: WalletsStatus.loaded,
          walletWithBalances: walletsWithState.sublist(1),
          notice: WalletNotice.recentlyDeleted(
            wallet: deletedWallet,
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => mockDeleteWalletUseCase.execute(
            DeleteWalletParams(wallet: deletedWallet),
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
            DeleteWalletParams(wallet: deletedWallet),
            traceId: traceId,
          ),
        ).thenAnswer(
          (_) async => AppResult<Null>.failure(AppException.test()),
        );
      },
      seed: () {
        return WalletsState(
          status: WalletsStatus.loaded,
          walletWithBalances: walletsWithState,
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        WalletsEvent.delete(deletedWallet),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <WalletsState>[
        WalletsState(
          status: WalletsStatus.loaded,
          walletWithBalances: walletsWithState.map((it) {
            final isDeleting =
                it.walletWithBalance.wallet.id == deletedWallet.id;
            if (!isDeleting) return it;
            return it.copyWith(status: WalletStatus.deleting);
          }).toList(),
        ),
        WalletsState(
          status: WalletsStatus.loaded,
          walletWithBalances: walletsWithState,
          notice: WalletNotice.deleteFailed(
            wallet: deletedWallet,
            exception: AppException.test(),
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => mockDeleteWalletUseCase.execute(
            DeleteWalletParams(wallet: deletedWallet),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<WalletsBloc, WalletsState>(
      'do nothing when wallet not found on walletWithBalances',
      seed: () {
        return const WalletsState(status: WalletsStatus.loaded);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        WalletsEvent.delete(deletedWallet),
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
      'emits [new updating walletWithBalances, '
      'new walletWithBalances with updated notice] '
      'when updateWalletUseCase returns success',
      seed: () {
        return WalletsState(
          status: WalletsStatus.loaded,
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
          status: WalletsStatus.loaded,
          walletWithBalances: walletsWithState.map((it) {
            final isUpdating =
                it.walletWithBalance.wallet.id == wallets.first.wallet.id;
            if (!isUpdating) return it;
            return it.copyWith(status: WalletStatus.updating);
          }).toList(),
        ),
        WalletsState(
          status: WalletsStatus.loaded,
          walletWithBalances: walletsWithState.map((it) {
            final isUpdating =
                it.walletWithBalance.wallet.id == wallets.first.wallet.id;
            if (!isUpdating) return it;
            return it.copyWith(
              status: WalletStatus.idle,
              walletWithBalance: it.walletWithBalance.copyWith(
                wallet: updatedFirstWallet,
              ),
            );
          }).toList(),
          notice: WalletNotice.recentlyUpdated(
            from: walletsWithState.first.walletWithBalance.wallet,
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
          status: WalletsStatus.loaded,
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
          status: WalletsStatus.loaded,
          walletWithBalances: walletsWithState.map((it) {
            final isUpdating =
                it.walletWithBalance.wallet.id == wallets.first.wallet.id;
            if (!isUpdating) return it;
            return it.copyWith(status: WalletStatus.updating);
          }).toList(),
        ),
        WalletsState(
          status: WalletsStatus.loaded,
          walletWithBalances: walletsWithState,
          notice: WalletNotice.updateFailed(
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
        return const WalletsState(status: WalletsStatus.loaded);
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
