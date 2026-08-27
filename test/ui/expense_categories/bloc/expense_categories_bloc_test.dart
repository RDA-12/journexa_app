import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/expense_category.dart';
import 'package:journexa_app/domain/use_cases/expense_category/delete_expense_category.dart';
import 'package:journexa_app/domain/use_cases/expense_category/get_all_expense_categories.dart';
import 'package:journexa_app/domain/use_cases/expense_category/update_expense_category.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';
import 'package:journexa_app/ui/expense_categories/bloc/expense_categories_bloc.dart';
import 'package:journexa_app/ui/shared/event_transform/event_transform.dart';
import 'package:mocktail/mocktail.dart';

class MockGetAllExpenseCategories extends Mock
    implements GetAllExpenseCategoriesUseCase {}

class MockUidGenerator extends Mock implements UidGenerator {}

class MockDeleteExpenseCategory extends Mock
    implements DeleteExpenseCategoryUseCase {}

class MockUpdateExpenseCategory extends Mock
    implements UpdateExpenseCategoryUseCase {}

void main() {
  const traceId = 'traceId';
  final expenseCategories = List.generate(5, (idx) {
    return ExpenseCategory(
      id: '$idx',
      name: 'name $idx',
      icon: 'icon',
      account: Account.user(
        parent: SystemDefinedAccount.rootExpense,
        name: 'name $idx',
        currentChildrenCount: idx,
      ),
    );
  });
  final expenseCategoriesWithState = expenseCategories
      .map(
        (it) => ExpenseCategoryWithState(category: it),
      )
      .toList();
  final updatedFirstCategory = expenseCategories.first.update(
    name: 'new name',
  );

  late GetAllExpenseCategoriesUseCase mockGetAllExpenseCategories;
  late UidGenerator mockUidGenerator;
  late DeleteExpenseCategoryUseCase mockDeleteExpenseCategory;
  late UpdateExpenseCategoryUseCase mockUpdateExpenseCategory;

  setUpAll(() {
    registerFallbackValue(
      const GetAllExpenseCategoriesParams(),
    );
    registerFallbackValue(
      DeleteExpenseCategoryParams(category: expenseCategories.first),
    );
    registerFallbackValue(
      UpdateExpenseCategoryParams(
        category: expenseCategories.first,
        name: 'new name',
      ),
    );
  });

  setUp(() {
    mockUidGenerator = MockUidGenerator();
    when(mockUidGenerator.generateUid).thenReturn(traceId);

    mockGetAllExpenseCategories = MockGetAllExpenseCategories();
    when(
      () => mockGetAllExpenseCategories.execute(
        any<GetAllExpenseCategoriesParams>(),
        traceId: traceId,
      ),
    ).thenAnswer(
      (_) async => AppResult.success(expenseCategories),
    );

    mockDeleteExpenseCategory = MockDeleteExpenseCategory();
    when(
      () => mockDeleteExpenseCategory.execute(
        any<DeleteExpenseCategoryParams>(),
        traceId: traceId,
      ),
    ).thenAnswer((_) async => const AppResult.success(null));

    mockUpdateExpenseCategory = MockUpdateExpenseCategory();
    when(
      () => mockUpdateExpenseCategory.execute(
        any<UpdateExpenseCategoryParams>(),
        traceId: traceId,
      ),
    ).thenAnswer(
      (_) async => AppResult.success(updatedFirstCategory),
    );
  });

  ExpenseCategoriesBloc buildBloc() {
    return ExpenseCategoriesBloc(
      getAllExpenseCategories: mockGetAllExpenseCategories,
      deleteExpenseCategory: mockDeleteExpenseCategory,
      updateExpenseCategory: mockUpdateExpenseCategory,
    )..customGenerator = mockUidGenerator;
  }

  test('has initial state of ExpenseCategoriesState.initial', () {
    final bloc = buildBloc();
    expect(bloc.state, const ExpenseCategoriesState());
  });

  group('load', () {
    blocTest<ExpenseCategoriesBloc, ExpenseCategoriesState>(
      'emits [loading, loaded] '
      'with correct categories '
      'when getAllExpenseCategoriesUseCase returns success',
      build: buildBloc,
      act: (bloc) => bloc.add(const ExpenseCategoriesEvent.load()),
      expect: () => <ExpenseCategoriesState>[
        const ExpenseCategoriesState(status: ExpenseCategoriesStatus.loading),
        ExpenseCategoriesState(
          status: ExpenseCategoriesStatus.loaded,
          categories: expenseCategoriesWithState,
        ),
      ],
      verify: (_) {
        verify(
          () => mockGetAllExpenseCategories.execute(
            const GetAllExpenseCategoriesParams(),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<ExpenseCategoriesBloc, ExpenseCategoriesState>(
      'emits [loading, failure] '
      'when getAllExpenseCategoriesUseCase returns failure',
      setUp: () {
        when(
          () => mockGetAllExpenseCategories.execute(
            const GetAllExpenseCategoriesParams(),
            traceId: traceId,
          ),
        ).thenAnswer(
          (_) async =>
              AppResult<List<ExpenseCategory>>.failure(AppException.test()),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const ExpenseCategoriesEvent.load()),
      expect: () => <ExpenseCategoriesState>[
        const ExpenseCategoriesState(status: ExpenseCategoriesStatus.loading),
        ExpenseCategoriesState(
          status: ExpenseCategoriesStatus.failure,
          exception: AppException.test(),
        ),
      ],
      verify: (_) {
        verify(
          () => mockGetAllExpenseCategories.execute(
            const GetAllExpenseCategoriesParams(),
            traceId: traceId,
          ),
        ).called(1);
      },
    );
  });

  group('search', () {
    blocTest<ExpenseCategoriesBloc, ExpenseCategoriesState>(
      'only process last event within debounce time',
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const ExpenseCategoriesEvent.search(query: 'q'))
        ..add(const ExpenseCategoriesEvent.search(query: 'que'))
        ..add(const ExpenseCategoriesEvent.search(query: 'query')),
      wait: kDefaultDebounceDuration + const Duration(milliseconds: 1),
      expect: () => <ExpenseCategoriesState>[
        const ExpenseCategoriesState(status: ExpenseCategoriesStatus.loading),
        ExpenseCategoriesState(
          status: ExpenseCategoriesStatus.loaded,
          categories: expenseCategoriesWithState,
        ),
      ],
      verify: (_) {
        verify(
          () => mockGetAllExpenseCategories.execute(
            const GetAllExpenseCategoriesParams(query: 'query'),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<ExpenseCategoriesBloc, ExpenseCategoriesState>(
      'emits [loading, loaded] '
      'with correct categories '
      'when getAllExpenseCategoriesUseCase returns success',
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const ExpenseCategoriesEvent.search(query: 'query')),
      wait: kDefaultDebounceDuration,
      expect: () => <ExpenseCategoriesState>[
        const ExpenseCategoriesState(status: ExpenseCategoriesStatus.loading),
        ExpenseCategoriesState(
          status: ExpenseCategoriesStatus.loaded,
          categories: expenseCategoriesWithState,
        ),
      ],
      verify: (_) {
        verify(
          () => mockGetAllExpenseCategories.execute(
            const GetAllExpenseCategoriesParams(query: 'query'),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<ExpenseCategoriesBloc, ExpenseCategoriesState>(
      'emits [loading, failure] '
      'when getAllExpenseCategoriesUseCase returns failure',
      setUp: () {
        when(
          () => mockGetAllExpenseCategories.execute(
            const GetAllExpenseCategoriesParams(query: 'query'),
            traceId: traceId,
          ),
        ).thenAnswer(
          (_) async =>
              AppResult<List<ExpenseCategory>>.failure(AppException.test()),
        );
      },
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const ExpenseCategoriesEvent.search(query: 'query')),
      wait: kDefaultDebounceDuration,
      expect: () => <ExpenseCategoriesState>[
        const ExpenseCategoriesState(status: ExpenseCategoriesStatus.loading),
        ExpenseCategoriesState(
          status: ExpenseCategoriesStatus.failure,
          exception: AppException.test(),
        ),
      ],
      verify: (_) {
        verify(
          () => mockGetAllExpenseCategories.execute(
            const GetAllExpenseCategoriesParams(query: 'query'),
            traceId: traceId,
          ),
        ).called(1);
      },
    );
  });

  group('delete', () {
    blocTest<ExpenseCategoriesBloc, ExpenseCategoriesState>(
      'emits [new categories, loaded new categories with notice] '
      'when deleteExpenseCategory returns success',
      seed: () {
        return ExpenseCategoriesState(
          status: ExpenseCategoriesStatus.loaded,
          categories: expenseCategoriesWithState,
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        ExpenseCategoriesEvent.delete(expenseCategories.first),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <ExpenseCategoriesState>[
        ExpenseCategoriesState(
          status: ExpenseCategoriesStatus.loaded,
          categories: expenseCategoriesWithState.map((it) {
            final isDeleting =
                it.category.id == expenseCategoriesWithState.first.category.id;
            if (!isDeleting) return it;
            return it.copyWith(status: ExpenseCategoryStatus.deleting);
          }).toList(),
        ),
        ExpenseCategoriesState(
          status: ExpenseCategoriesStatus.loaded,
          categories: expenseCategoriesWithState.sublist(1),
          notice: ExpenseCategoryNotice.recentlyDeleted(
            category: expenseCategories.first,
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => mockDeleteExpenseCategory.execute(
            DeleteExpenseCategoryParams(category: expenseCategories.first),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<ExpenseCategoriesBloc, ExpenseCategoriesState>(
      'emits [new categories, new idle categories and failed notice] '
      'when deleteExpenseCategory returns failure',
      setUp: () {
        when(
          () => mockDeleteExpenseCategory.execute(
            DeleteExpenseCategoryParams(category: expenseCategories.first),
            traceId: traceId,
          ),
        ).thenAnswer(
          (_) async => AppResult<Null>.failure(AppException.test()),
        );
      },
      seed: () {
        return ExpenseCategoriesState(
          status: ExpenseCategoriesStatus.loaded,
          categories: expenseCategoriesWithState,
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        ExpenseCategoriesEvent.delete(expenseCategories.first),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <ExpenseCategoriesState>[
        ExpenseCategoriesState(
          status: ExpenseCategoriesStatus.loaded,
          categories: expenseCategoriesWithState.map((it) {
            final isDeleting =
                it.category.id == expenseCategoriesWithState.first.category.id;
            if (!isDeleting) return it;
            return it.copyWith(status: ExpenseCategoryStatus.deleting);
          }).toList(),
        ),
        ExpenseCategoriesState(
          status: ExpenseCategoriesStatus.loaded,
          categories: expenseCategoriesWithState,
          notice: ExpenseCategoryNotice.deleteFailed(
            category: expenseCategories.first,
            exception: AppException.test(),
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => mockDeleteExpenseCategory.execute(
            DeleteExpenseCategoryParams(
              category: expenseCategories.first,
            ),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<ExpenseCategoriesBloc, ExpenseCategoriesState>(
      'do nothing when category not found on categories',
      seed: () {
        return const ExpenseCategoriesState(
          status: ExpenseCategoriesStatus.loaded,
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        ExpenseCategoriesEvent.delete(expenseCategories.first),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <ExpenseCategoriesState>[],
      verify: (_) {
        verifyZeroInteractions(mockDeleteExpenseCategory);
      },
    );
  });

  group('update', () {
    blocTest<ExpenseCategoriesBloc, ExpenseCategoriesState>(
      'emits [new updating categories, '
      'new categories with updated notice] '
      'when updateExpenseCategory returns success',
      seed: () {
        return ExpenseCategoriesState(
          status: ExpenseCategoriesStatus.loaded,
          categories: expenseCategoriesWithState,
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        ExpenseCategoriesEvent.update(
          expenseCategories.first,
          name: updatedFirstCategory.name,
        ),
      ),
      expect: () => <ExpenseCategoriesState>[
        ExpenseCategoriesState(
          status: ExpenseCategoriesStatus.loaded,
          categories: expenseCategoriesWithState.map((it) {
            final isUpdating =
                it.category.id == expenseCategoriesWithState.first.category.id;
            if (!isUpdating) return it;
            return it.copyWith(status: ExpenseCategoryStatus.updating);
          }).toList(),
        ),
        ExpenseCategoriesState(
          status: ExpenseCategoriesStatus.loaded,
          categories: expenseCategoriesWithState.map((it) {
            final isUpdating =
                it.category.id == expenseCategoriesWithState.first.category.id;
            if (!isUpdating) return it;
            return it.copyWith(
              status: ExpenseCategoryStatus.idle,
              category: updatedFirstCategory,
            );
          }).toList(),
          notice: ExpenseCategoryNotice.recentlyUpdated(
            from: expenseCategoriesWithState.first.category,
            to: updatedFirstCategory,
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => mockUpdateExpenseCategory.execute(
            UpdateExpenseCategoryParams(
              category: expenseCategories.first,
              name: updatedFirstCategory.name,
            ),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<ExpenseCategoriesBloc, ExpenseCategoriesState>(
      'emits [new categories, '
      'new categories with idle status and updateFailure notice] '
      'when updateExpenseCategory returns failure',
      setUp: () {
        when(
          () => mockUpdateExpenseCategory.execute(
            UpdateExpenseCategoryParams(
              category: expenseCategories.first,
              name: updatedFirstCategory.name,
            ),
            traceId: traceId,
          ),
        ).thenAnswer(
          (_) async => AppResult<ExpenseCategory>.failure(AppException.test()),
        );
      },
      seed: () {
        return ExpenseCategoriesState(
          status: ExpenseCategoriesStatus.loaded,
          categories: expenseCategoriesWithState,
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        ExpenseCategoriesEvent.update(
          expenseCategories.first,
          name: updatedFirstCategory.name,
        ),
      ),
      expect: () => <ExpenseCategoriesState>[
        ExpenseCategoriesState(
          status: ExpenseCategoriesStatus.loaded,
          categories: expenseCategoriesWithState.map((it) {
            final isUpdating =
                it.category.id == expenseCategoriesWithState.first.category.id;
            if (!isUpdating) return it;
            return it.copyWith(status: ExpenseCategoryStatus.updating);
          }).toList(),
        ),
        ExpenseCategoriesState(
          status: ExpenseCategoriesStatus.loaded,
          categories: expenseCategoriesWithState,
          notice: ExpenseCategoryNotice.updateFailed(
            category: expenseCategories.first,
            exception: AppException.test(),
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => mockUpdateExpenseCategory.execute(
            UpdateExpenseCategoryParams(
              category: expenseCategories.first,
              name: updatedFirstCategory.name,
            ),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<ExpenseCategoriesBloc, ExpenseCategoriesState>(
      'do nothing when account not found on categories',
      seed: () {
        return const ExpenseCategoriesState(
          status: ExpenseCategoriesStatus.loaded,
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        ExpenseCategoriesEvent.update(
          expenseCategories.first,
          name: updatedFirstCategory.name,
        ),
      ),
      expect: () => <ExpenseCategoriesState>[],
      verify: (_) {
        verifyZeroInteractions(mockUpdateExpenseCategory);
      },
    );
  });
}
