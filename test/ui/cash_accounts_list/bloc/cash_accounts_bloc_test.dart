import 'package:bloc_test/bloc_test.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/journal.dart';
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

  late GetAllCashAccountsUseCase mockGetAllCashAccounts;
  late UidGenerator mockUidGenerator;

  setUpAll(() {
    registerFallbackValue(const GetAllCashAccountsParams());
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
  });

  CashAccountsBloc buildBloc() {
    return CashAccountsBloc(
      getAllCashAccounts: mockGetAllCashAccounts,
    )..customGenerator = mockUidGenerator;
  }

  test('has initial state of CashAccountsState.initial', () {
    final bloc = buildBloc();
    expect(bloc.state, const CashAccountsState.initial());
  });

  group('load', () {
    blocTest<CashAccountsBloc, CashAccountsState>(
      'emits [CashAccountsBloc.loading, CashAccountsBloc.loaded] '
      'with correct account balances '
      'when getAllCashAccountsUseCase returns success',
      build: buildBloc,
      act: (bloc) => bloc.add(const CashAccountsEvent.load()),
      expect: () => <CashAccountsState>[
        const CashAccountsState.loading(),
        CashAccountsState.loaded(cashAccounts),
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
      'emits [CashAccountsBloc.loading, CashAccountsBloc.failure] '
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
        const CashAccountsState.loading(),
        CashAccountsState.failure(AppException.test()),
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
        const CashAccountsState.loading(),
        CashAccountsState.loaded(cashAccounts),
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
      'emits [CashAccountsBloc.loading, CashAccountsBloc.loaded] '
      'with correct account balances '
      'when getAllCashAccountsUseCase returns success',
      build: buildBloc,
      act: (bloc) => bloc.add(const CashAccountsEvent.search(query: 'query')),
      wait: kDefaultDebounceDuration,
      expect: () => <CashAccountsState>[
        const CashAccountsState.loading(),
        CashAccountsState.loaded(cashAccounts),
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
      'emits [CashAccountsBloc.loading, CashAccountsBloc.failure] '
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
        const CashAccountsState.loading(),
        CashAccountsState.failure(AppException.test()),
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
}
