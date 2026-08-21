import 'package:bloc_test/bloc_test.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/journal.dart';
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
    return AccountBalance(
      account: Account(
        code: '10.000${idx + 1}',
        name: 'asset $idx',
        type: AccountType.asset,
      ),
      balance: Decimal.fromInt(idx * 1000),
    );
  });
  final walletsWithState = wallets.map(
    (it) {
      return AccountBalanceWithState(
        accountBalance: it,
      );
    },
  ).toList();
  final updatedFirstAccount = wallets.first.account.update(
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
      DeleteAccountParams(account: wallets.first.account),
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
      'with correct account balances '
      'when getAllWalletsUseCase returns success',
      build: buildBloc,
      act: (bloc) => bloc.add(const WalletsEvent.load()),
      expect: () => <WalletsState>[
        const WalletsState(status: WalletsStatus.loading),
        WalletsState(
          status: WalletsStatus.loaded,
          accountBalances: walletsWithState,
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
              AppResult<List<AccountBalance>>.failure(AppException.test()),
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
          accountBalances: walletsWithState,
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
      'with correct account balances '
      'when getAllWalletsUseCase returns success',
      build: buildBloc,
      act: (bloc) => bloc.add(const WalletsEvent.search(query: 'query')),
      wait: kDefaultDebounceDuration,
      expect: () => <WalletsState>[
        const WalletsState(status: WalletsStatus.loading),
        WalletsState(
          status: WalletsStatus.loaded,
          accountBalances: walletsWithState,
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
              AppResult<List<AccountBalance>>.failure(AppException.test()),
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
      'emits [new accountBalances, loaded new accountBalances with notice] '
      'when deleteAccountUseCase returns success',
      seed: () {
        return WalletsState(
          status: WalletsStatus.loaded,
          accountBalances: walletsWithState,
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        WalletsEvent.delete(wallets.first.account),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <WalletsState>[
        WalletsState(
          status: WalletsStatus.loaded,
          accountBalances: walletsWithState.map((it) {
            final isDeleting =
                it.accountBalance.account.code == wallets.first.account.code;
            if (!isDeleting) return it;
            return it.copyWith(status: WalletStatus.deleting);
          }).toList(),
        ),
        WalletsState(
          status: WalletsStatus.loaded,
          accountBalances: walletsWithState.sublist(1),
          notice: WalletNotice.recentlyDeleted(
            account: wallets.first.account,
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => mockDeleteAccountUseCase.execute(
            DeleteAccountParams(account: wallets.first.account),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<WalletsBloc, WalletsState>(
      'emits [new accountBalances, new idle accountBalances and failed notice] '
      'when deleteAccountUseCase returns failure',
      setUp: () {
        when(
          () => mockDeleteAccountUseCase.execute(
            DeleteAccountParams(account: wallets.first.account),
            traceId: traceId,
          ),
        ).thenAnswer(
          (_) async => AppResult<Null>.failure(AppException.test()),
        );
      },
      seed: () {
        return WalletsState(
          status: WalletsStatus.loaded,
          accountBalances: walletsWithState,
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        WalletsEvent.delete(wallets.first.account),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <WalletsState>[
        WalletsState(
          status: WalletsStatus.loaded,
          accountBalances: walletsWithState.map((it) {
            final isDeleting =
                it.accountBalance.account.code == wallets.first.account.code;
            if (!isDeleting) return it;
            return it.copyWith(status: WalletStatus.deleting);
          }).toList(),
        ),
        WalletsState(
          status: WalletsStatus.loaded,
          accountBalances: walletsWithState,
          notice: WalletNotice.deleteFailed(
            account: wallets.first.account,
            exception: AppException.test(),
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => mockDeleteAccountUseCase.execute(
            DeleteAccountParams(account: wallets.first.account),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<WalletsBloc, WalletsState>(
      'do nothing when account not found on accountBalances',
      seed: () {
        return const WalletsState(status: WalletsStatus.loaded);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        WalletsEvent.delete(wallets.first.account),
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
      'emits [new updating accountBalances, '
      'new accountBalances with updated notice] '
      'when updateAccountUseCase returns success',
      seed: () {
        return WalletsState(
          status: WalletsStatus.loaded,
          accountBalances: walletsWithState,
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        WalletsEvent.update(
          wallets.first.account,
          name: updatedFirstAccount.name,
        ),
      ),
      expect: () => <WalletsState>[
        WalletsState(
          status: WalletsStatus.loaded,
          accountBalances: walletsWithState.map((it) {
            final isUpdating =
                it.accountBalance.account.code == wallets.first.account.code;
            if (!isUpdating) return it;
            return it.copyWith(status: WalletStatus.updating);
          }).toList(),
        ),
        WalletsState(
          status: WalletsStatus.loaded,
          accountBalances: walletsWithState.map((it) {
            final isUpdating =
                it.accountBalance.account.code == wallets.first.account.code;
            if (!isUpdating) return it;
            return it.copyWith(
              status: WalletStatus.idle,
              accountBalance: it.accountBalance.copyWith(
                account: updatedFirstAccount,
              ),
            );
          }).toList(),
          notice: WalletNotice.recentlyUpdated(
            from: walletsWithState.first.accountBalance.account,
            to: updatedFirstAccount,
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => mockUpdateAccountUseCase.execute(
            UpdateAccountParams(
              code: wallets.first.account.code,
              name: updatedFirstAccount.name,
            ),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<WalletsBloc, WalletsState>(
      'emits [new accountBalances, '
      'new accountBalances with idle status and updateFailure notice] '
      'when updateAccountUseCase returns failure',
      setUp: () {
        when(
          () => mockUpdateAccountUseCase.execute(
            UpdateAccountParams(
              code: wallets.first.account.code,
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
          accountBalances: walletsWithState,
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        WalletsEvent.update(
          wallets.first.account,
          name: updatedFirstAccount.name,
        ),
      ),
      expect: () => <WalletsState>[
        WalletsState(
          status: WalletsStatus.loaded,
          accountBalances: walletsWithState.map((it) {
            final isUpdating =
                it.accountBalance.account.code == wallets.first.account.code;
            if (!isUpdating) return it;
            return it.copyWith(status: WalletStatus.updating);
          }).toList(),
        ),
        WalletsState(
          status: WalletsStatus.loaded,
          accountBalances: walletsWithState,
          notice: WalletNotice.updateFailed(
            account: wallets.first.account,
            exception: AppException.test(),
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => mockUpdateAccountUseCase.execute(
            UpdateAccountParams(
              code: wallets.first.account.code,
              name: updatedFirstAccount.name,
            ),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<WalletsBloc, WalletsState>(
      'do nothing when account not found on accountBalances',
      seed: () {
        return const WalletsState(status: WalletsStatus.loaded);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        WalletsEvent.update(
          wallets.first.account,
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
