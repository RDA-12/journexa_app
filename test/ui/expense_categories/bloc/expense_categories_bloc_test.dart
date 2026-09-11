import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/expense_category.dart';
import 'package:journexa_app/domain/use_cases/expense_category/delete_expense_category.dart';
import 'package:journexa_app/domain/use_cases/expense_category/update_expense_category.dart';
import 'package:journexa_app/domain/use_cases/expense_category/watch_expense_categories.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';
import 'package:journexa_app/ui/expense_categories/bloc/expense_categories_bloc.dart';
import 'package:journexa_app/ui/shared/event_transform/event_transform.dart';
import 'package:mocktail/mocktail.dart';

class MockWatchExpenseCategories extends Mock
    implements WatchExpenseCategoriesUseCase {}

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
      account: Account.sub(
        parent: SystemDefinedAccount.expenseParent,
        name: 'name $idx',
        currentChildrenCount: idx,
      ),
    );
  });
  final expenseCategoriesWithState = expenseCategories
      .map(
        (it) => ExpenseCategoryUIModel(category: it),
      )
      .toList();
  final updatedFirstCategory = expenseCategories.first.update(
    name: 'new name',
  );

  late WatchExpenseCategoriesUseCase mockWatchExpenseCategories;
  late UidGenerator mockUidGenerator;
  late DeleteExpenseCategoryUseCase mockDeleteExpenseCategory;
  late UpdateExpenseCategoryUseCase mockUpdateExpenseCategory;

  setUpAll(() {
    registerFallbackValue(
      const WatchExpenseCategoriesParams(),
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

    mockWatchExpenseCategories = MockWatchExpenseCategories();
    when(
      () => mockWatchExpenseCategories.execute(
        any<WatchExpenseCategoriesParams>(),
        traceId: traceId,
      ),
    ).thenAnswer(
      (_) => Stream.value(AppResult.success(expenseCategories)),
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
      watchExpenseCategories: mockWatchExpenseCategories,
      deleteExpenseCategory: mockDeleteExpenseCategory,
      updateExpenseCategory: mockUpdateExpenseCategory,
    )..customGenerator = mockUidGenerator;
  }

  test('has initial state of ExpenseCategoriesState.initial', () {
    final bloc = buildBloc();
    expect(bloc.state, const ExpenseCategoriesState());
  });

  group('subscriptionRequested', () {
    blocTest<ExpenseCategoriesBloc, ExpenseCategoriesState>(
      'emits [loading, loaded] '
      'with correct categories '
      'when watchExpenseCategoriesUseCase returns success',
      build: buildBloc,
      act: (bloc) => bloc.add(
        const ExpenseCategoriesEvent.subscriptionRequested(),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <ExpenseCategoriesState>[
        const ExpenseCategoriesState(status: ExpenseCategoriesUIStatus.loading),
        ExpenseCategoriesState(
          status: ExpenseCategoriesUIStatus.loaded,
          categories: expenseCategoriesWithState,
        ),
      ],
      verify: (_) {
        verify(
          () => mockWatchExpenseCategories.execute(
            const WatchExpenseCategoriesParams(),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<ExpenseCategoriesBloc, ExpenseCategoriesState>(
      'emits [loading, loaded] '
      'with correct categories and params '
      'when watchExpenseCategoriesUseCase returns success',
      build: buildBloc,
      act: (bloc) => bloc.add(
        const ExpenseCategoriesEvent.subscriptionRequested(query: 'query'),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <ExpenseCategoriesState>[
        const ExpenseCategoriesState(status: ExpenseCategoriesUIStatus.loading),
        ExpenseCategoriesState(
          status: ExpenseCategoriesUIStatus.loaded,
          categories: expenseCategoriesWithState,
        ),
      ],
      verify: (_) {
        verify(
          () => mockWatchExpenseCategories.execute(
            const WatchExpenseCategoriesParams(query: 'query'),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<ExpenseCategoriesBloc, ExpenseCategoriesState>(
      'emits [loading, failure] '
      'when getAllExpenseCategoriesUseCase emits failure',
      setUp: () {
        when(
          () => mockWatchExpenseCategories.execute(
            const WatchExpenseCategoriesParams(),
            traceId: traceId,
          ),
        ).thenAnswer(
          (_) => Stream.value(
            AppResult<List<ExpenseCategory>>.failure(AppException.test()),
          ),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const ExpenseCategoriesEvent.subscriptionRequested(),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <ExpenseCategoriesState>[
        const ExpenseCategoriesState(status: ExpenseCategoriesUIStatus.loading),
        ExpenseCategoriesState(
          status: ExpenseCategoriesUIStatus.failure,
          exception: AppException.test(),
        ),
      ],
      verify: (_) {
        verify(
          () => mockWatchExpenseCategories.execute(
            const WatchExpenseCategoriesParams(),
            traceId: traceId,
          ),
        ).called(1);
      },
    );
  });

  group('delete', () {
    blocTest<ExpenseCategoriesBloc, ExpenseCategoriesState>(
      'emits [new categories, loaded with notice] '
      'when deleteExpenseCategory returns success',
      seed: () {
        return ExpenseCategoriesState(
          status: ExpenseCategoriesUIStatus.loaded,
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
          status: ExpenseCategoriesUIStatus.loaded,
          categories: expenseCategoriesWithState.map((it) {
            final isDeleting =
                it.category.id == expenseCategoriesWithState.first.category.id;
            if (!isDeleting) return it;
            return it.copyWith(status: ExpenseCategoryUIStatus.deleting);
          }).toList(),
        ),
        ExpenseCategoriesState(
          status: ExpenseCategoriesUIStatus.loaded,
          categories: expenseCategoriesWithState.map((it) {
            final isDeleting =
                it.category.id == expenseCategoriesWithState.first.category.id;
            if (!isDeleting) return it;
            return it.copyWith(status: ExpenseCategoryUIStatus.deleting);
          }).toList(),
          notice: ExpenseCategoryUINotice.recentlyDeleted(
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
          status: ExpenseCategoriesUIStatus.loaded,
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
          status: ExpenseCategoriesUIStatus.loaded,
          categories: expenseCategoriesWithState.map((it) {
            final isDeleting =
                it.category.id == expenseCategoriesWithState.first.category.id;
            if (!isDeleting) return it;
            return it.copyWith(status: ExpenseCategoryUIStatus.deleting);
          }).toList(),
        ),
        ExpenseCategoriesState(
          status: ExpenseCategoriesUIStatus.loaded,
          categories: expenseCategoriesWithState,
          notice: ExpenseCategoryUINotice.deleteFailed(
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
          status: ExpenseCategoriesUIStatus.loaded,
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
      'emits [new updating categories, loaded with updated notice] '
      'when updateExpenseCategory returns success',
      seed: () {
        return ExpenseCategoriesState(
          status: ExpenseCategoriesUIStatus.loaded,
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
          status: ExpenseCategoriesUIStatus.loaded,
          categories: expenseCategoriesWithState.map((it) {
            final isUpdating =
                it.category.id == expenseCategoriesWithState.first.category.id;
            if (!isUpdating) return it;
            return it.copyWith(status: ExpenseCategoryUIStatus.updating);
          }).toList(),
        ),
        ExpenseCategoriesState(
          status: ExpenseCategoriesUIStatus.loaded,
          categories: expenseCategoriesWithState.map((it) {
            final isUpdating =
                it.category.id == expenseCategoriesWithState.first.category.id;
            if (!isUpdating) return it;
            return it.copyWith(status: ExpenseCategoryUIStatus.updating);
          }).toList(),
          notice: ExpenseCategoryUINotice.recentlyUpdated(
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
          status: ExpenseCategoriesUIStatus.loaded,
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
          status: ExpenseCategoriesUIStatus.loaded,
          categories: expenseCategoriesWithState.map((it) {
            final isUpdating =
                it.category.id == expenseCategoriesWithState.first.category.id;
            if (!isUpdating) return it;
            return it.copyWith(status: ExpenseCategoryUIStatus.updating);
          }).toList(),
        ),
        ExpenseCategoriesState(
          status: ExpenseCategoriesUIStatus.loaded,
          categories: expenseCategoriesWithState,
          notice: ExpenseCategoryUINotice.updateFailed(
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
          status: ExpenseCategoriesUIStatus.loaded,
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
