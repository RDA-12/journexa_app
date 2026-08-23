import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
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

class MockDeleteIncomeCategory extends Mock implements DeleteAccountUseCase {}

class MockUpdateIncomeCategory extends Mock implements UpdateAccountUseCase {}

void main() {
  const traceId = 'traceId';
  final incomeCategories = List.generate(5, (idx) {
    return IncomeCategory(
      id: '$idx',
      name: 'name $idx',
      icon: 'icon',
      account: Account.user(
        parent: SystemDefinedAccount.rootRevenue,
        name: 'name $idx',
        currentChildrenCount: idx,
      ),
    );
  });
  final incomeCategoriesWithState = incomeCategories
      .map(
        (it) => IncomeCategoryWithState(category: it),
      )
      .toList();
  final updatedFirstCategory = incomeCategories.first.update(
    name: 'new name',
  );

  late GetAllIncomeCategoriesUseCase mockGetAllIncomeCategories;
  late UidGenerator mockUidGenerator;
  late DeleteAccountUseCase mockDeleteIncomeCategory;
  late UpdateAccountUseCase mockUpdateIncomeCategory;

  setUpAll(() {
    registerFallbackValue(
      const GetAllIncomeCategoriesParams(),
    );
    registerFallbackValue(
      DeleteAccountParams(account: incomeCategories.first.account),
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

    mockDeleteIncomeCategory = MockDeleteIncomeCategory();
    when(
      () => mockDeleteIncomeCategory.execute(
        any<DeleteAccountParams>(),
        traceId: traceId,
      ),
    ).thenAnswer((_) async => const AppResult.success(null));

    mockUpdateIncomeCategory = MockUpdateIncomeCategory();
    when(
      () => mockUpdateIncomeCategory.execute(
        any<UpdateAccountParams>(),
        traceId: traceId,
      ),
    ).thenAnswer(
      (_) async => AppResult.success(updatedFirstCategory.account),
    );
  });

  IncomeCategoriesBloc buildBloc() {
    return IncomeCategoriesBloc(
      getAllIncomeCategories: mockGetAllIncomeCategories,
      deleteIncomeCategory: mockDeleteIncomeCategory,
      updateIncomeCategory: mockUpdateIncomeCategory,
    )..customGenerator = mockUidGenerator;
  }

  test('has initial state of IncomeCategoriesState.initial', () {
    final bloc = buildBloc();
    expect(bloc.state, const IncomeCategoriesState());
  });

  group('load', () {
    blocTest<IncomeCategoriesBloc, IncomeCategoriesState>(
      'emits [loading, loaded] '
      'with correct categories '
      'when getAllIncomeCategoriesUseCase returns success',
      build: buildBloc,
      act: (bloc) => bloc.add(const IncomeCategoriesEvent.load()),
      expect: () => <IncomeCategoriesState>[
        const IncomeCategoriesState(status: IncomeCategoriesStatus.loading),
        IncomeCategoriesState(
          status: IncomeCategoriesStatus.loaded,
          categories: incomeCategoriesWithState,
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
          (_) async =>
              AppResult<List<IncomeCategory>>.failure(AppException.test()),
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
          categories: incomeCategoriesWithState,
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
      'with correct categories '
      'when getAllIncomeCategoriesUseCase returns success',
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const IncomeCategoriesEvent.search(query: 'query')),
      wait: kDefaultDebounceDuration,
      expect: () => <IncomeCategoriesState>[
        const IncomeCategoriesState(status: IncomeCategoriesStatus.loading),
        IncomeCategoriesState(
          status: IncomeCategoriesStatus.loaded,
          categories: incomeCategoriesWithState,
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
          (_) async =>
              AppResult<List<IncomeCategory>>.failure(AppException.test()),
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
      'emits [new categories, loaded new categories with notice] '
      'when deleteIncomeCategory returns success',
      seed: () {
        return IncomeCategoriesState(
          status: IncomeCategoriesStatus.loaded,
          categories: incomeCategoriesWithState,
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
          categories: incomeCategoriesWithState.map((it) {
            final isDeleting =
                it.category.id == incomeCategoriesWithState.first.category.id;
            if (!isDeleting) return it;
            return it.copyWith(status: IncomeCategoryStatus.deleting);
          }).toList(),
        ),
        IncomeCategoriesState(
          status: IncomeCategoriesStatus.loaded,
          categories: incomeCategoriesWithState.sublist(1),
          notice: IncomeCategoryNotice.recentlyDeleted(
            category: incomeCategories.first,
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => mockDeleteIncomeCategory.execute(
            DeleteAccountParams(account: incomeCategories.first.account),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<IncomeCategoriesBloc, IncomeCategoriesState>(
      'emits [new categories, new idle categories and failed notice] '
      'when deleteIncomeCategory returns failure',
      setUp: () {
        when(
          () => mockDeleteIncomeCategory.execute(
            DeleteAccountParams(account: incomeCategories.first.account),
            traceId: traceId,
          ),
        ).thenAnswer(
          (_) async => AppResult<Null>.failure(AppException.test()),
        );
      },
      seed: () {
        return IncomeCategoriesState(
          status: IncomeCategoriesStatus.loaded,
          categories: incomeCategoriesWithState,
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
          categories: incomeCategoriesWithState.map((it) {
            final isDeleting =
                it.category.id == incomeCategoriesWithState.first.category.id;
            if (!isDeleting) return it;
            return it.copyWith(status: IncomeCategoryStatus.deleting);
          }).toList(),
        ),
        IncomeCategoriesState(
          status: IncomeCategoriesStatus.loaded,
          categories: incomeCategoriesWithState,
          notice: IncomeCategoryNotice.deleteFailed(
            category: incomeCategories.first,
            exception: AppException.test(),
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => mockDeleteIncomeCategory.execute(
            DeleteAccountParams(account: incomeCategories.first.account),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<IncomeCategoriesBloc, IncomeCategoriesState>(
      'do nothing when category not found on categories',
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
        verifyZeroInteractions(mockDeleteIncomeCategory);
      },
    );
  });

  group('update', () {
    blocTest<IncomeCategoriesBloc, IncomeCategoriesState>(
      'emits [new updating categories, '
      'new categories with updated notice] '
      'when updateIncomeCategory returns success',
      seed: () {
        return IncomeCategoriesState(
          status: IncomeCategoriesStatus.loaded,
          categories: incomeCategoriesWithState,
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        IncomeCategoriesEvent.update(
          incomeCategories.first,
          name: updatedFirstCategory.name,
        ),
      ),
      expect: () => <IncomeCategoriesState>[
        IncomeCategoriesState(
          status: IncomeCategoriesStatus.loaded,
          categories: incomeCategoriesWithState.map((it) {
            final isUpdating =
                it.category.id == incomeCategoriesWithState.first.category.id;
            if (!isUpdating) return it;
            return it.copyWith(status: IncomeCategoryStatus.updating);
          }).toList(),
        ),
        IncomeCategoriesState(
          status: IncomeCategoriesStatus.loaded,
          categories: incomeCategoriesWithState.map((it) {
            final isUpdating =
                it.category.id == incomeCategoriesWithState.first.category.id;
            if (!isUpdating) return it;
            return it.copyWith(
              status: IncomeCategoryStatus.idle,
              category: updatedFirstCategory,
            );
          }).toList(),
          notice: IncomeCategoryNotice.recentlyUpdated(
            from: incomeCategoriesWithState.first.category,
            to: updatedFirstCategory,
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => mockUpdateIncomeCategory.execute(
            UpdateAccountParams(
              code: incomeCategories.first.account.code,
              name: updatedFirstCategory.name,
            ),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<IncomeCategoriesBloc, IncomeCategoriesState>(
      'emits [new categories, '
      'new categories with idle status and updateFailure notice] '
      'when updateIncomeCategory returns failure',
      setUp: () {
        when(
          () => mockUpdateIncomeCategory.execute(
            UpdateAccountParams(
              code: incomeCategories.first.account.code,
              name: updatedFirstCategory.name,
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
          categories: incomeCategoriesWithState,
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        IncomeCategoriesEvent.update(
          incomeCategories.first,
          name: updatedFirstCategory.name,
        ),
      ),
      expect: () => <IncomeCategoriesState>[
        IncomeCategoriesState(
          status: IncomeCategoriesStatus.loaded,
          categories: incomeCategoriesWithState.map((it) {
            final isUpdating =
                it.category.id == incomeCategoriesWithState.first.category.id;
            if (!isUpdating) return it;
            return it.copyWith(status: IncomeCategoryStatus.updating);
          }).toList(),
        ),
        IncomeCategoriesState(
          status: IncomeCategoriesStatus.loaded,
          categories: incomeCategoriesWithState,
          notice: IncomeCategoryNotice.updateFailed(
            category: incomeCategories.first,
            exception: AppException.test(),
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => mockUpdateIncomeCategory.execute(
            UpdateAccountParams(
              code: incomeCategories.first.account.code,
              name: updatedFirstCategory.name,
            ),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<IncomeCategoriesBloc, IncomeCategoriesState>(
      'do nothing when account not found on categories',
      seed: () {
        return const IncomeCategoriesState(
          status: IncomeCategoriesStatus.loaded,
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        IncomeCategoriesEvent.update(
          incomeCategories.first,
          name: updatedFirstCategory.name,
        ),
      ),
      expect: () => <IncomeCategoriesState>[],
      verify: (_) {
        verifyZeroInteractions(mockUpdateIncomeCategory);
      },
    );
  });
}
