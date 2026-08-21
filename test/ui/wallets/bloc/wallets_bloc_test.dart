import 'package:bloc_test/bloc_test.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/use_cases/account/delete_account.dart';
import 'package:journexa_app/domain/use_cases/account/update_account.dart';
import 'package:journexa_app/domain/use_cases/wallet/get_all_wallets.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';
import 'package:journexa_app/ui/shared/event_transform/event_transform.dart';
import 'package:journexa_app/ui/wallets/bloc/wallets_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockGetAllWallets extends Mock implements GetAllWalletsUseCase {}

class MockUidGenerator extends Mock implements UidGenerator {}

class MockDeleteAccountUseCase extends Mock implements DeleteAccountUseCase {}

class MockUpdateAccountUseCase extends Mock implements UpdateAccountUseCase {}

void main() {
  const traceId = 'traceId';
  final wallets = List.generate(5, (idx) {
    return WalletWithBalance(
      wallet: Wallet(
        id: '$idx',
        name: 'asset $idx',
        account: Account(
          code: '10.000${idx + 1}',
          name: 'asset $idx',
          type: AccountType.asset,
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
  final updatedFirstAccount = wallets.first.wallet.account.update(
    name: 'new name',
  );

  late GetAllWalletsUseCase mockGetAllWallets;
  late UidGenerator mockUidGenerator;
  late DeleteAccountUseCase mockDeleteAccountUseCase;
  late MockUpdateAccountUseCase mockUpdateAccountUseCase;

  setUpAll(() {
    registerFallbackValue(
      const GetAllWalletsParams(),
    );
    registerFallbackValue(
      DeleteAccountParams(account: wallets.first.wallet.account),
    );
    registerFallbackValue(
      const UpdateAccountParams(code: '12345'),
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

    mockDeleteAccountUseCase = MockDeleteAccountUseCase();
    when(
      () => mockDeleteAccountUseCase.execute(
        any<DeleteAccountParams>(),
        traceId: traceId,
      ),
    ).thenAnswer((_) async => const AppResult.success(null));

    mockUpdateAccountUseCase = MockUpdateAccountUseCase();
    when(
      () => mockUpdateAccountUseCase.execute(
        any<UpdateAccountParams>(),
        traceId: traceId,
      ),
    ).thenAnswer(
      (_) async => AppResult.success(updatedFirstAccount),
    );
  });

  WalletsBloc buildBloc() {
    return WalletsBloc(
      getAllWallets: mockGetAllWallets,
      deleteAccount: mockDeleteAccountUseCase,
      updateAccount: mockUpdateAccountUseCase,
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
    blocTest<WalletsBloc, WalletsState>(
      'emits [new walletWithBalances, '
      'loaded new walletWithBalances with notice] '
      'when deleteAccountUseCase returns success',
      seed: () {
        return WalletsState(
          status: WalletsStatus.loaded,
          walletWithBalances: walletsWithState,
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        WalletsEvent.delete(wallets.first.wallet.account),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <WalletsState>[
        WalletsState(
          status: WalletsStatus.loaded,
          walletWithBalances: walletsWithState.map((it) {
            final isDeleting =
                it.walletWithBalance.wallet.account.code ==
                wallets.first.wallet.account.code;
            if (!isDeleting) return it;
            return it.copyWith(status: WalletStatus.deleting);
          }).toList(),
        ),
        WalletsState(
          status: WalletsStatus.loaded,
          walletWithBalances: walletsWithState.sublist(1),
          notice: WalletNotice.recentlyDeleted(
            account: wallets.first.wallet.account,
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => mockDeleteAccountUseCase.execute(
            DeleteAccountParams(account: wallets.first.wallet.account),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<WalletsBloc, WalletsState>(
      'emits [new walletWithBalances, '
      'new idle walletWithBalances and failed notice] '
      'when deleteAccountUseCase returns failure',
      setUp: () {
        when(
          () => mockDeleteAccountUseCase.execute(
            DeleteAccountParams(account: wallets.first.wallet.account),
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
        WalletsEvent.delete(wallets.first.wallet.account),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <WalletsState>[
        WalletsState(
          status: WalletsStatus.loaded,
          walletWithBalances: walletsWithState.map((it) {
            final isDeleting =
                it.walletWithBalance.wallet.account.code ==
                wallets.first.wallet.account.code;
            if (!isDeleting) return it;
            return it.copyWith(status: WalletStatus.deleting);
          }).toList(),
        ),
        WalletsState(
          status: WalletsStatus.loaded,
          walletWithBalances: walletsWithState,
          notice: WalletNotice.deleteFailed(
            account: wallets.first.wallet.account,
            exception: AppException.test(),
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => mockDeleteAccountUseCase.execute(
            DeleteAccountParams(account: wallets.first.wallet.account),
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
        WalletsEvent.delete(wallets.first.wallet.account),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <WalletsState>[],
      verify: (_) {
        verifyZeroInteractions(mockDeleteAccountUseCase);
      },
    );
  });

  group('update', () {
    blocTest<WalletsBloc, WalletsState>(
      'emits [new updating walletWithBalances, '
      'new walletWithBalances with updated notice] '
      'when updateAccountUseCase returns success',
      seed: () {
        return WalletsState(
          status: WalletsStatus.loaded,
          walletWithBalances: walletsWithState,
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        WalletsEvent.update(
          wallets.first.wallet.account,
          name: updatedFirstAccount.name,
        ),
      ),
      expect: () => <WalletsState>[
        WalletsState(
          status: WalletsStatus.loaded,
          walletWithBalances: walletsWithState.map((it) {
            final isUpdating =
                it.walletWithBalance.wallet.account.code ==
                wallets.first.wallet.account.code;
            if (!isUpdating) return it;
            return it.copyWith(status: WalletStatus.updating);
          }).toList(),
        ),
        WalletsState(
          status: WalletsStatus.loaded,
          walletWithBalances: walletsWithState.map((it) {
            final isUpdating =
                it.walletWithBalance.wallet.account.code ==
                wallets.first.wallet.account.code;
            if (!isUpdating) return it;
            return it.copyWith(
              status: WalletStatus.idle,
              walletWithBalance: it.walletWithBalance.copyWith(
                wallet: it.walletWithBalance.wallet.copyWith(
                  name: updatedFirstAccount.name,
                  account: updatedFirstAccount,
                ),
              ),
            );
          }).toList(),
          notice: WalletNotice.recentlyUpdated(
            from: walletsWithState.first.walletWithBalance.wallet.account,
            to: updatedFirstAccount,
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => mockUpdateAccountUseCase.execute(
            UpdateAccountParams(
              code: wallets.first.wallet.account.code,
              name: updatedFirstAccount.name,
            ),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<WalletsBloc, WalletsState>(
      'emits [new walletWithBalances, '
      'new walletWithBalances with idle status and updateFailure notice] '
      'when updateAccountUseCase returns failure',
      setUp: () {
        when(
          () => mockUpdateAccountUseCase.execute(
            UpdateAccountParams(
              code: wallets.first.wallet.account.code,
              name: updatedFirstAccount.name,
            ),
            traceId: traceId,
          ),
        ).thenAnswer(
          (_) async => AppResult<Account>.failure(AppException.test()),
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
          wallets.first.wallet.account,
          name: updatedFirstAccount.name,
        ),
      ),
      expect: () => <WalletsState>[
        WalletsState(
          status: WalletsStatus.loaded,
          walletWithBalances: walletsWithState.map((it) {
            final isUpdating =
                it.walletWithBalance.wallet.account.code ==
                wallets.first.wallet.account.code;
            if (!isUpdating) return it;
            return it.copyWith(status: WalletStatus.updating);
          }).toList(),
        ),
        WalletsState(
          status: WalletsStatus.loaded,
          walletWithBalances: walletsWithState,
          notice: WalletNotice.updateFailed(
            account: wallets.first.wallet.account,
            exception: AppException.test(),
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => mockUpdateAccountUseCase.execute(
            UpdateAccountParams(
              code: wallets.first.wallet.account.code,
              name: updatedFirstAccount.name,
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
          wallets.first.wallet.account,
          name: updatedFirstAccount.name,
        ),
      ),
      expect: () => <WalletsState>[],
      verify: (_) {
        verifyZeroInteractions(mockUpdateAccountUseCase);
      },
    );
  });
}
