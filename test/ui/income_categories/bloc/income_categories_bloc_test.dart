import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/use_cases/account/delete_account.dart';
import 'package:journexa_app/domain/use_cases/account/update_account.dart';
import 'package:journexa_app/domain/use_cases/income_category/get_all_income_categories.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';
import 'package:journexa_app/ui/income_categories/bloc/income_categories_bloc.dart';
import 'package:journexa_app/ui/shared/event_transform/event_transform.dart';
import 'package:mocktail/mocktail.dart';

class MockGetAllIncomeCategories extends Mock
    implements GetAllIncomeCategoriesUseCase {}

class MockUidGenerator extends Mock implements UidGenerator {}

class MockDeleteAccountUseCase extends Mock implements DeleteAccountUseCase {}

class MockUpdateAccountUseCase extends Mock implements UpdateAccountUseCase {}

void main() {
  const traceId = 'traceId';
  final incomeCategories = List.generate(5, (idx) {
    return Account(
      code: '40.000${idx + 1}',
      name: 'income $idx',
      type: AccountType.revenue,
    );
  });
  final incomeCategoriesWithState = incomeCategories
      .map(
        (it) => AccountWithState(account: it),
      )
      .toList();
  final updatedFirstAccount = incomeCategories.first.update(
    name: 'new name',
  );

  late GetAllIncomeCategoriesUseCase mockGetAllIncomeCategories;
  late UidGenerator mockUidGenerator;
  late DeleteAccountUseCase mockDeleteAccountUseCase;
  late MockUpdateAccountUseCase mockUpdateAccountUseCase;

  setUpAll(() {
    registerFallbackValue(
      const GetAllIncomeCategoriesParams(),
    );
    registerFallbackValue(
      DeleteAccountParams(account: incomeCategories.first),
    );
    registerFallbackValue(
      const UpdateAccountParams(code: '12345'),
    );
  });

  setUp(() {
    mockUidGenerator = MockUidGenerator();
    when(mockUidGenerator.generateUid).thenReturn(traceId);

    mockGetAllIncomeCategories = MockGetAllIncomeCategories();
    when(
      () => mockGetAllIncomeCategories.execute(
        any<GetAllIncomeCategoriesParams>(),
        traceId: traceId,
      ),
    ).thenAnswer(
      (_) async => AppResult.success(incomeCategories),
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

  IncomeCategoriesBloc buildBloc() {
    return IncomeCategoriesBloc(
      getAllIncomeCategories: mockGetAllIncomeCategories,
      deleteAccount: mockDeleteAccountUseCase,
      updateAccount: mockUpdateAccountUseCase,
    )..customGenerator = mockUidGenerator;
  }

  test('has initial state of IncomeCategoriesState.initial', () {
    final bloc = buildBloc();
    expect(bloc.state, const IncomeCategoriesState());
  });

  group('load', () {
    blocTest<IncomeCategoriesBloc, IncomeCategoriesState>(
      'emits [loading, loaded] '
      'with correct account balances '
      'when getAllIncomeCategoriesUseCase returns success',
      build: buildBloc,
      act: (bloc) => bloc.add(const IncomeCategoriesEvent.load()),
      expect: () => <IncomeCategoriesState>[
        const IncomeCategoriesState(status: IncomeCategoriesStatus.loading),
        IncomeCategoriesState(
          status: IncomeCategoriesStatus.loaded,
          accounts: incomeCategoriesWithState,
        ),
      ],
      verify: (_) {
        verify(
          () => mockGetAllIncomeCategories.execute(
            const GetAllIncomeCategoriesParams(),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<IncomeCategoriesBloc, IncomeCategoriesState>(
      'emits [loading, failure] '
      'when getAllIncomeCategoriesUseCase returns failure',
      setUp: () {
        when(
          () => mockGetAllIncomeCategories.execute(
            const GetAllIncomeCategoriesParams(),
            traceId: traceId,
          ),
        ).thenAnswer(
          (_) async => AppResult<List<Account>>.failure(AppException.test()),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const IncomeCategoriesEvent.load()),
      expect: () => <IncomeCategoriesState>[
        const IncomeCategoriesState(status: IncomeCategoriesStatus.loading),
        IncomeCategoriesState(
          status: IncomeCategoriesStatus.failure,
          exception: AppException.test(),
        ),
      ],
      verify: (_) {
        verify(
          () => mockGetAllIncomeCategories.execute(
            const GetAllIncomeCategoriesParams(),
            traceId: traceId,
          ),
        ).called(1);
      },
    );
  });

  group('search', () {
    blocTest<IncomeCategoriesBloc, IncomeCategoriesState>(
      'only process last event within debounce time',
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const IncomeCategoriesEvent.search(query: 'q'))
        ..add(const IncomeCategoriesEvent.search(query: 'que'))
        ..add(const IncomeCategoriesEvent.search(query: 'query')),
      wait: kDefaultDebounceDuration + const Duration(milliseconds: 1),
      expect: () => <IncomeCategoriesState>[
        const IncomeCategoriesState(status: IncomeCategoriesStatus.loading),
        IncomeCategoriesState(
          status: IncomeCategoriesStatus.loaded,
          accounts: incomeCategoriesWithState,
        ),
      ],
      verify: (_) {
        verify(
          () => mockGetAllIncomeCategories.execute(
            const GetAllIncomeCategoriesParams(query: 'query'),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<IncomeCategoriesBloc, IncomeCategoriesState>(
      'emits [loading, loaded] '
      'with correct account balances '
      'when getAllIncomeCategoriesUseCase returns success',
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const IncomeCategoriesEvent.search(query: 'query')),
      wait: kDefaultDebounceDuration,
      expect: () => <IncomeCategoriesState>[
        const IncomeCategoriesState(status: IncomeCategoriesStatus.loading),
        IncomeCategoriesState(
          status: IncomeCategoriesStatus.loaded,
          accounts: incomeCategoriesWithState,
        ),
      ],
      verify: (_) {
        verify(
          () => mockGetAllIncomeCategories.execute(
            const GetAllIncomeCategoriesParams(query: 'query'),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<IncomeCategoriesBloc, IncomeCategoriesState>(
      'emits [loading, failure] '
      'when getAllIncomeCategoriesUseCase returns failure',
      setUp: () {
        when(
          () => mockGetAllIncomeCategories.execute(
            const GetAllIncomeCategoriesParams(query: 'query'),
            traceId: traceId,
          ),
        ).thenAnswer(
          (_) async => AppResult<List<Account>>.failure(AppException.test()),
        );
      },
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const IncomeCategoriesEvent.search(query: 'query')),
      wait: kDefaultDebounceDuration,
      expect: () => <IncomeCategoriesState>[
        const IncomeCategoriesState(status: IncomeCategoriesStatus.loading),
        IncomeCategoriesState(
          status: IncomeCategoriesStatus.failure,
          exception: AppException.test(),
        ),
      ],
      verify: (_) {
        verify(
          () => mockGetAllIncomeCategories.execute(
            const GetAllIncomeCategoriesParams(query: 'query'),
            traceId: traceId,
          ),
        ).called(1);
      },
    );
  });

  group('delete', () {
    blocTest<IncomeCategoriesBloc, IncomeCategoriesState>(
      'emits [new accountBalances, loaded new accountBalances with notice] '
      'when deleteAccountUseCase returns success',
      seed: () {
        return IncomeCategoriesState(
          status: IncomeCategoriesStatus.loaded,
          accounts: incomeCategoriesWithState,
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        IncomeCategoriesEvent.delete(incomeCategories.first),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <IncomeCategoriesState>[
        IncomeCategoriesState(
          status: IncomeCategoriesStatus.loaded,
          accounts: incomeCategoriesWithState.map((it) {
            final isDeleting = it.account.code == incomeCategories.first.code;
            if (!isDeleting) return it;
            return it.copyWith(status: IncomeCategoryStatus.deleting);
          }).toList(),
        ),
        IncomeCategoriesState(
          status: IncomeCategoriesStatus.loaded,
          accounts: incomeCategoriesWithState.sublist(1),
          notice: IncomeCategoryNotice.recentlyDeleted(
            account: incomeCategories.first,
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => mockDeleteAccountUseCase.execute(
            DeleteAccountParams(account: incomeCategories.first),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<IncomeCategoriesBloc, IncomeCategoriesState>(
      'emits [new accountBalances, new idle accountBalances and failed notice] '
      'when deleteAccountUseCase returns failure',
      setUp: () {
        when(
          () => mockDeleteAccountUseCase.execute(
            DeleteAccountParams(account: incomeCategories.first),
            traceId: traceId,
          ),
        ).thenAnswer(
          (_) async => AppResult<Null>.failure(AppException.test()),
        );
      },
      seed: () {
        return IncomeCategoriesState(
          status: IncomeCategoriesStatus.loaded,
          accounts: incomeCategoriesWithState,
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        IncomeCategoriesEvent.delete(incomeCategories.first),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <IncomeCategoriesState>[
        IncomeCategoriesState(
          status: IncomeCategoriesStatus.loaded,
          accounts: incomeCategoriesWithState.map((it) {
            final isDeleting = it.account.code == incomeCategories.first.code;
            if (!isDeleting) return it;
            return it.copyWith(status: IncomeCategoryStatus.deleting);
          }).toList(),
        ),
        IncomeCategoriesState(
          status: IncomeCategoriesStatus.loaded,
          accounts: incomeCategoriesWithState,
          notice: IncomeCategoryNotice.deleteFailed(
            account: incomeCategories.first,
            exception: AppException.test(),
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => mockDeleteAccountUseCase.execute(
            DeleteAccountParams(account: incomeCategories.first),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<IncomeCategoriesBloc, IncomeCategoriesState>(
      'do nothing when account not found on accountBalances',
      seed: () {
        return const IncomeCategoriesState(
          status: IncomeCategoriesStatus.loaded,
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        IncomeCategoriesEvent.delete(incomeCategories.first),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <IncomeCategoriesState>[],
      verify: (_) {
        verifyZeroInteractions(mockDeleteAccountUseCase);
      },
    );
  });

  group('update', () {
    blocTest<IncomeCategoriesBloc, IncomeCategoriesState>(
      'emits [new updating accountBalances, '
      'new accountBalances with updated notice] '
      'when updateAccountUseCase returns success',
      seed: () {
        return IncomeCategoriesState(
          status: IncomeCategoriesStatus.loaded,
          accounts: incomeCategoriesWithState,
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        IncomeCategoriesEvent.update(
          incomeCategories.first,
          name: updatedFirstAccount.name,
        ),
      ),
      expect: () => <IncomeCategoriesState>[
        IncomeCategoriesState(
          status: IncomeCategoriesStatus.loaded,
          accounts: incomeCategoriesWithState.map((it) {
            final isUpdating = it.account.code == incomeCategories.first.code;
            if (!isUpdating) return it;
            return it.copyWith(status: IncomeCategoryStatus.updating);
          }).toList(),
        ),
        IncomeCategoriesState(
          status: IncomeCategoriesStatus.loaded,
          accounts: incomeCategoriesWithState.map((it) {
            final isUpdating = it.account.code == incomeCategories.first.code;
            if (!isUpdating) return it;
            return it.copyWith(
              status: IncomeCategoryStatus.idle,
              account: updatedFirstAccount,
            );
          }).toList(),
          notice: IncomeCategoryNotice.recentlyUpdated(
            from: incomeCategoriesWithState.first.account,
            to: updatedFirstAccount,
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => mockUpdateAccountUseCase.execute(
            UpdateAccountParams(
              code: incomeCategories.first.code,
              name: updatedFirstAccount.name,
            ),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<IncomeCategoriesBloc, IncomeCategoriesState>(
      'emits [new accountBalances, '
      'new accountBalances with idle status and updateFailure notice] '
      'when updateAccountUseCase returns failure',
      setUp: () {
        when(
          () => mockUpdateAccountUseCase.execute(
            UpdateAccountParams(
              code: incomeCategories.first.code,
              name: updatedFirstAccount.name,
            ),
            traceId: traceId,
          ),
        ).thenAnswer(
          (_) async => AppResult<Account>.failure(AppException.test()),
        );
      },
      seed: () {
        return IncomeCategoriesState(
          status: IncomeCategoriesStatus.loaded,
          accounts: incomeCategoriesWithState,
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        IncomeCategoriesEvent.update(
          incomeCategories.first,
          name: updatedFirstAccount.name,
        ),
      ),
      expect: () => <IncomeCategoriesState>[
        IncomeCategoriesState(
          status: IncomeCategoriesStatus.loaded,
          accounts: incomeCategoriesWithState.map((it) {
            final isUpdating = it.account.code == incomeCategories.first.code;
            if (!isUpdating) return it;
            return it.copyWith(status: IncomeCategoryStatus.updating);
          }).toList(),
        ),
        IncomeCategoriesState(
          status: IncomeCategoriesStatus.loaded,
          accounts: incomeCategoriesWithState,
          notice: IncomeCategoryNotice.updateFailed(
            account: incomeCategories.first,
            exception: AppException.test(),
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => mockUpdateAccountUseCase.execute(
            UpdateAccountParams(
              code: incomeCategories.first.code,
              name: updatedFirstAccount.name,
            ),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<IncomeCategoriesBloc, IncomeCategoriesState>(
      'do nothing when account not found on accountBalances',
      seed: () {
        return const IncomeCategoriesState(
          status: IncomeCategoriesStatus.loaded,
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        IncomeCategoriesEvent.update(
          incomeCategories.first,
          name: updatedFirstAccount.name,
        ),
      ),
      expect: () => <IncomeCategoriesState>[],
      verify: (_) {
        verifyZeroInteractions(mockUpdateAccountUseCase);
      },
    );
  });
}
