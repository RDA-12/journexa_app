import 'package:bloc_test/bloc_test.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/journal.dart';
import 'package:journexa_app/domain/use_cases/account/delete_account.dart';
import 'package:journexa_app/domain/use_cases/account/get_all_wallets.dart';
import 'package:journexa_app/domain/use_cases/account/update_account.dart';
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
      'emits [new accountBalances, '
      'loaded new accountBalances and recentlyDeletedAccount] '
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
            return it.copyWith(isDeleting: isDeleting);
          }).toList(),
        ),
        WalletsState(
          status: WalletsStatus.loaded,
          accountBalances: walletsWithState.sublist(1),
          recentlyDeletedAccount: wallets.first.account,
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
      'emits [new accountBalances, deleteFailure] '
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
            return it.copyWith(isDeleting: isDeleting);
          }).toList(),
        ),
        WalletsState(
          status: WalletsStatus.deleteFailure,
          deleteException: AppException.test(),
          accountBalances: walletsWithState,
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

    blocTest<WalletsBloc, WalletsState>(
      'drops duplicate events',
      seed: () {
        return WalletsState(
          status: WalletsStatus.loaded,
          accountBalances: walletsWithState,
        );
      },
      build: buildBloc,
      act: (bloc) => bloc
        ..add(
          WalletsEvent.delete(wallets.first.account),
        )
        ..add(
          WalletsEvent.delete(wallets.first.account),
        )
        ..add(
          WalletsEvent.delete(wallets.first.account),
        )
        ..add(
          WalletsEvent.delete(wallets[1].account),
        ),
      wait: kDefaultDebounceDuration,
      expect: () {
        final firstDeletionAccounts = walletsWithState.map((it) {
          final isDeleting =
              it.accountBalance.account.code == wallets.first.account.code;
          return it.copyWith(isDeleting: isDeleting);
        }).toList();
        final secondDeletionAccounts = firstDeletionAccounts.sublist(1).map(
          (it) {
            final isDeleting =
                it.accountBalance.account.code == wallets[1].account.code;
            return it.copyWith(isDeleting: isDeleting);
          },
        ).toList();
        return <WalletsState>[
          WalletsState(
            status: WalletsStatus.loaded,
            accountBalances: firstDeletionAccounts,
          ),
          WalletsState(
            status: WalletsStatus.loaded,
            accountBalances: firstDeletionAccounts.sublist(1),
            recentlyDeletedAccount: wallets.first.account,
          ),
          WalletsState(
            status: WalletsStatus.loaded,
            accountBalances: secondDeletionAccounts,
            recentlyDeletedAccount: wallets.first.account,
          ),
          WalletsState(
            status: WalletsStatus.loaded,
            accountBalances: secondDeletionAccounts.sublist(1),
            recentlyDeletedAccount: wallets[1].account,
          ),
        ];
      },
      verify: (_) {
        verify(
          () => mockDeleteAccountUseCase.execute(
            any<DeleteAccountParams>(),
            traceId: traceId,
          ),
        ).called(2);
      },
    );
  });

  group('update', () {
    blocTest<WalletsBloc, WalletsState>(
      'emits [new accountBalances, '
      'loaded new accountBalances and recentlyUpdatedAccount] '
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
            return it.copyWith(isUpdating: isUpdating);
          }).toList(),
        ),
        WalletsState(
          status: WalletsStatus.loaded,
          accountBalances: walletsWithState.map((it) {
            final isUpdating =
                it.accountBalance.account.code == wallets.first.account.code;
            if (!isUpdating) return it;
            return it.copyWith(
              isUpdating: false,
              accountBalance: it.accountBalance.copyWith(
                account: updatedFirstAccount,
              ),
            );
          }).toList(),
          recentlyUpdatedAccount: updatedFirstAccount,
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
      'emits [new accountBalances, updateFailure] '
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
            return it.copyWith(isUpdating: isUpdating);
          }).toList(),
        ),
        WalletsState(
          status: WalletsStatus.updateFailure,
          updateException: AppException.test(),
          accountBalances: walletsWithState,
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

    blocTest<WalletsBloc, WalletsState>(
      'has restartable transformers',
      setUp: () {
        when(
          () => mockUpdateAccountUseCase.execute(
            any<UpdateAccountParams>(),
            traceId: any(named: 'traceId'),
          ),
        ).thenAnswer((invocation) async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return AppResult<Account>.success(updatedFirstAccount);
        });
      },
      seed: () {
        return WalletsState(
          status: WalletsStatus.loaded,
          accountBalances: walletsWithState,
        );
      },
      build: buildBloc,
      wait: const Duration(milliseconds: 300),
      act: (bloc) => bloc
        ..add(
          WalletsEvent.update(
            wallets.first.account,
            name: 'lol',
          ),
        )
        ..add(
          WalletsEvent.update(
            wallets.first.account,
            name: 'tester',
          ),
        )
        ..add(
          WalletsEvent.update(
            wallets.first.account,
            name: updatedFirstAccount.name,
          ),
        ),
      expect: () {
        return <WalletsState>[
          WalletsState(
            status: WalletsStatus.loaded,
            accountBalances: walletsWithState.map((it) {
              final isUpdating =
                  it.accountBalance.account.code == wallets.first.account.code;
              return it.copyWith(isUpdating: isUpdating);
            }).toList(),
          ),
          WalletsState(
            status: WalletsStatus.loaded,
            accountBalances: walletsWithState.map((it) {
              final isUpdating =
                  it.accountBalance.account.code == wallets.first.account.code;
              if (!isUpdating) return it;
              return it.copyWith(
                isUpdating: false,
                accountBalance: it.accountBalance.copyWith(
                  account: updatedFirstAccount,
                ),
              );
            }).toList(),
            recentlyUpdatedAccount: updatedFirstAccount,
          ),
        ];
      },
      verify: (_) {
        verify(
          () => mockUpdateAccountUseCase.execute(
            any<UpdateAccountParams>(),
            traceId: traceId,
          ),
        ).called(3);
      },
    );
  });
}
