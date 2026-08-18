import 'package:bloc_test/bloc_test.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/journal.dart';
import 'package:journexa_app/domain/use_cases/account/delete_account.dart';
import 'package:journexa_app/domain/use_cases/account/get_all_cash_accounts.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';
import 'package:journexa_app/ui/cash_accounts_list/bloc/cash_accounts_bloc.dart';
import 'package:journexa_app/ui/shared/event_transform/event_transform.dart';
import 'package:mocktail/mocktail.dart';

class MockGetAllCashAccounts extends Mock
    implements GetAllCashAccountsUseCase {}

class MockUidGenerator extends Mock implements UidGenerator {}

class MockDeleteAccountUseCase extends Mock implements DeleteAccountUseCase {}

void main() {
  const traceId = 'traceId';
  final cashAccounts = List.generate(5, (idx) {
    return AccountBalance(
      account: Account(
        code: '10.000${idx + 1}',
        name: 'asset $idx',
        type: AccountType.asset,
      ),
      balance: Decimal.fromInt(idx * 1000),
    );
  });
  final cashAccountsWithState = cashAccounts.map(
    (it) {
      return AccountBalanceWithState(
        accountBalance: it,
      );
    },
  ).toList();

  late GetAllCashAccountsUseCase mockGetAllCashAccounts;
  late UidGenerator mockUidGenerator;
  late DeleteAccountUseCase mockDeleteAccountUseCase;

  setUpAll(() {
    registerFallbackValue(const GetAllCashAccountsParams());
    registerFallbackValue(
      DeleteAccountParams(account: cashAccounts.first.account),
    );
  });

  setUp(() {
    mockUidGenerator = MockUidGenerator();
    when(mockUidGenerator.generateUid).thenReturn(traceId);

    mockGetAllCashAccounts = MockGetAllCashAccounts();
    when(
      () => mockGetAllCashAccounts.execute(
        any<GetAllCashAccountsParams>(),
        traceId: traceId,
      ),
    ).thenAnswer(
      (_) async => AppResult.success(cashAccounts),
    );

    mockDeleteAccountUseCase = MockDeleteAccountUseCase();
    when(
      () => mockDeleteAccountUseCase.execute(
        any<DeleteAccountParams>(),
        traceId: traceId,
      ),
    ).thenAnswer((_) async => const AppResult.success(null));
  });

  CashAccountsBloc buildBloc() {
    return CashAccountsBloc(
      getAllCashAccounts: mockGetAllCashAccounts,
      deleteAccount: mockDeleteAccountUseCase,
    )..customGenerator = mockUidGenerator;
  }

  test('has initial state of CashAccountsState.initial', () {
    final bloc = buildBloc();
    expect(bloc.state, const CashAccountsState());
  });

  group('load', () {
    blocTest<CashAccountsBloc, CashAccountsState>(
      'emits [loading, loaded] '
      'with correct account balances '
      'when getAllCashAccountsUseCase returns success',
      build: buildBloc,
      act: (bloc) => bloc.add(const CashAccountsEvent.load()),
      expect: () => <CashAccountsState>[
        const CashAccountsState(status: CashAccountsStatus.loading),
        CashAccountsState(
          status: CashAccountsStatus.loaded,
          accountBalances: cashAccountsWithState,
        ),
      ],
      verify: (_) {
        verify(
          () => mockGetAllCashAccounts.execute(
            const GetAllCashAccountsParams(),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<CashAccountsBloc, CashAccountsState>(
      'emits [loading, failure] '
      'when getAllCashAccountsUseCase returns failure',
      setUp: () {
        when(
          () => mockGetAllCashAccounts.execute(
            const GetAllCashAccountsParams(),
            traceId: traceId,
          ),
        ).thenAnswer(
          (_) async =>
              AppResult<List<AccountBalance>>.failure(AppException.test()),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const CashAccountsEvent.load()),
      expect: () => <CashAccountsState>[
        const CashAccountsState(status: CashAccountsStatus.loading),
        CashAccountsState(
          status: CashAccountsStatus.failure,
          exception: AppException.test(),
        ),
      ],
      verify: (_) {
        verify(
          () => mockGetAllCashAccounts.execute(
            const GetAllCashAccountsParams(),
            traceId: traceId,
          ),
        ).called(1);
      },
    );
  });

  group('search', () {
    blocTest<CashAccountsBloc, CashAccountsState>(
      'only process last event within debounce time',
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const CashAccountsEvent.search(query: 'q'))
        ..add(const CashAccountsEvent.search(query: 'que'))
        ..add(const CashAccountsEvent.search(query: 'query')),
      wait: kDefaultDebounceDuration + const Duration(milliseconds: 1),
      expect: () => <CashAccountsState>[
        const CashAccountsState(status: CashAccountsStatus.loading),
        CashAccountsState(
          status: CashAccountsStatus.loaded,
          accountBalances: cashAccountsWithState,
        ),
      ],
      verify: (_) {
        verify(
          () => mockGetAllCashAccounts.execute(
            const GetAllCashAccountsParams(query: 'query'),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<CashAccountsBloc, CashAccountsState>(
      'emits [loading, loaded] '
      'with correct account balances '
      'when getAllCashAccountsUseCase returns success',
      build: buildBloc,
      act: (bloc) => bloc.add(const CashAccountsEvent.search(query: 'query')),
      wait: kDefaultDebounceDuration,
      expect: () => <CashAccountsState>[
        const CashAccountsState(status: CashAccountsStatus.loading),
        CashAccountsState(
          status: CashAccountsStatus.loaded,
          accountBalances: cashAccountsWithState,
        ),
      ],
      verify: (_) {
        verify(
          () => mockGetAllCashAccounts.execute(
            const GetAllCashAccountsParams(query: 'query'),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<CashAccountsBloc, CashAccountsState>(
      'emits [loading, failure] '
      'when getAllCashAccountsUseCase returns failure',
      setUp: () {
        when(
          () => mockGetAllCashAccounts.execute(
            const GetAllCashAccountsParams(query: 'query'),
            traceId: traceId,
          ),
        ).thenAnswer(
          (_) async =>
              AppResult<List<AccountBalance>>.failure(AppException.test()),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const CashAccountsEvent.search(query: 'query')),
      wait: kDefaultDebounceDuration,
      expect: () => <CashAccountsState>[
        const CashAccountsState(status: CashAccountsStatus.loading),
        CashAccountsState(
          status: CashAccountsStatus.failure,
          exception: AppException.test(),
        ),
      ],
      verify: (_) {
        verify(
          () => mockGetAllCashAccounts.execute(
            const GetAllCashAccountsParams(query: 'query'),
            traceId: traceId,
          ),
        ).called(1);
      },
    );
  });

  group('delete', () {
    blocTest<CashAccountsBloc, CashAccountsState>(
      'emits [new accountBalances, '
      'loaded new accountBalances and recentlyDeletedAccount] '
      'when deleteAccountUseCase returns success',
      seed: () {
        return CashAccountsState(
          status: CashAccountsStatus.loaded,
          accountBalances: cashAccountsWithState,
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        CashAccountsEvent.delete(cashAccounts.first.account),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <CashAccountsState>[
        CashAccountsState(
          status: CashAccountsStatus.loaded,
          accountBalances: cashAccountsWithState.map((it) {
            final isDeleting =
                it.accountBalance.account.code ==
                cashAccounts.first.account.code;
            return it.copyWith(isDeleting: isDeleting);
          }).toList(),
        ),
        CashAccountsState(
          status: CashAccountsStatus.loaded,
          accountBalances: cashAccountsWithState.sublist(1),
          recentlyDeletedAccount: cashAccounts.first.account,
        ),
      ],
      verify: (_) {
        verify(
          () => mockDeleteAccountUseCase.execute(
            DeleteAccountParams(account: cashAccounts.first.account),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<CashAccountsBloc, CashAccountsState>(
      'emits [new accountBalances, deleteFailure] '
      'when deleteAccountUseCase returns failure',
      setUp: () {
        when(
          () => mockDeleteAccountUseCase.execute(
            DeleteAccountParams(account: cashAccounts.first.account),
            traceId: traceId,
          ),
        ).thenAnswer(
          (_) async => AppResult<Null>.failure(AppException.test()),
        );
      },
      seed: () {
        return CashAccountsState(
          status: CashAccountsStatus.loaded,
          accountBalances: cashAccountsWithState,
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        CashAccountsEvent.delete(cashAccounts.first.account),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <CashAccountsState>[
        CashAccountsState(
          status: CashAccountsStatus.loaded,
          accountBalances: cashAccountsWithState.map((it) {
            final isDeleting =
                it.accountBalance.account.code ==
                cashAccounts.first.account.code;
            return it.copyWith(isDeleting: isDeleting);
          }).toList(),
        ),
        CashAccountsState(
          status: CashAccountsStatus.deleteFailure,
          deleteException: AppException.test(),
          accountBalances: cashAccountsWithState,
        ),
      ],
      verify: (_) {
        verify(
          () => mockDeleteAccountUseCase.execute(
            DeleteAccountParams(account: cashAccounts.first.account),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<CashAccountsBloc, CashAccountsState>(
      'do nothing when account not found on accountBalances',
      seed: () {
        return const CashAccountsState(status: CashAccountsStatus.loaded);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        CashAccountsEvent.delete(cashAccounts.first.account),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <CashAccountsState>[],
      verify: (_) {
        verifyZeroInteractions(mockDeleteAccountUseCase);
      },
    );

    blocTest<CashAccountsBloc, CashAccountsState>(
      'drops duplicate events',
      seed: () {
        return CashAccountsState(
          status: CashAccountsStatus.loaded,
          accountBalances: cashAccountsWithState,
        );
      },
      build: buildBloc,
      act: (bloc) => bloc
        ..add(
          CashAccountsEvent.delete(cashAccounts.first.account),
        )
        ..add(
          CashAccountsEvent.delete(cashAccounts.first.account),
        )
        ..add(
          CashAccountsEvent.delete(cashAccounts.first.account),
        )
        ..add(
          CashAccountsEvent.delete(cashAccounts[1].account),
        ),
      wait: kDefaultDebounceDuration,
      expect: () {
        final firstDeletionAccounts = cashAccountsWithState.map((it) {
          final isDeleting =
              it.accountBalance.account.code == cashAccounts.first.account.code;
          return it.copyWith(isDeleting: isDeleting);
        }).toList();
        final secondDeletionAccounts = firstDeletionAccounts.sublist(1).map(
          (it) {
            final isDeleting =
                it.accountBalance.account.code == cashAccounts[1].account.code;
            return it.copyWith(isDeleting: isDeleting);
          },
        ).toList();
        return <CashAccountsState>[
          CashAccountsState(
            status: CashAccountsStatus.loaded,
            accountBalances: firstDeletionAccounts,
          ),
          CashAccountsState(
            status: CashAccountsStatus.loaded,
            accountBalances: firstDeletionAccounts.sublist(1),
            recentlyDeletedAccount: cashAccounts.first.account,
          ),
          CashAccountsState(
            status: CashAccountsStatus.loaded,
            accountBalances: secondDeletionAccounts,
            recentlyDeletedAccount: cashAccounts.first.account,
          ),
          CashAccountsState(
            status: CashAccountsStatus.loaded,
            accountBalances: secondDeletionAccounts.sublist(1),
            recentlyDeletedAccount: cashAccounts[1].account,
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
}
