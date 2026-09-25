import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/domain/use_cases/income_category/delete_income_category.dart';
import 'package:journexa_app/domain/use_cases/income_category/update_income_category.dart';
import 'package:journexa_app/domain/use_cases/income_category/watch_income_categories.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';
import 'package:journexa_app/ui/income_categories/bloc/income_categories_bloc.dart';
import 'package:journexa_app/ui/shared/event_transform/event_transform.dart';
import 'package:mocktail/mocktail.dart';

class MockWatchIncomeCategories extends Mock
    implements WatchIncomeCategoriesUseCase;

class MockUidGenerator extends Mock implements UidGenerator;

class MockDeleteIncomeCategory extends Mock
    implements DeleteIncomeCategoryUseCase;

class MockUpdateIncomeCategory extends Mock
    implements UpdateIncomeCategoryUseCase;

void main() {
  const traceId = 'traceId';
  final incomeCategories = List.generate(5, (idx) {
    return IncomeCategory(
      id: '$idx',
      name: 'name $idx',
      icon: 'icon',
      account: Account.sub(
        parent: SystemDefinedAccount.incomeParent,
        name: 'name $idx',
        currentChildrenCount: idx,
      ),
    );
  });
  final updatedFirstCategory = incomeCategories.first.update(
    name: 'new name',
  );

  late WatchIncomeCategoriesUseCase mockWatchIncomeCategories;
  late UidGenerator mockUidGenerator;
  late DeleteIncomeCategoryUseCase mockDeleteIncomeCategory;
  late UpdateIncomeCategoryUseCase mockUpdateIncomeCategory;

  setUpAll(() {
    registerFallbackValue(
      const WatchIncomeCategoriesParams(),
    );
    registerFallbackValue(
      DeleteIncomeCategoryParams(category: incomeCategories.first),
    );
    registerFallbackValue(
      UpdateIncomeCategoryParams(
        category: incomeCategories.first,
        name: 'new name',
      ),
    );
  });

  setUp(() {
    mockUidGenerator = MockUidGenerator();
    when(mockUidGenerator.generateUid).thenReturn(traceId);

    mockWatchIncomeCategories = MockWatchIncomeCategories();
    when(
      () => mockWatchIncomeCategories.execute(
        any<WatchIncomeCategoriesParams>(),
        traceId: traceId,
      ),
    ).thenAnswer(
      (_) => Stream.value(AppResult.success(incomeCategories)),
    );

    mockDeleteIncomeCategory = MockDeleteIncomeCategory();
    when(
      () => mockDeleteIncomeCategory.execute(
        any<DeleteIncomeCategoryParams>(),
        traceId: traceId,
      ),
    ).thenAnswer((_) async => const AppResult.success(null));

    mockUpdateIncomeCategory = MockUpdateIncomeCategory();
    when(
      () => mockUpdateIncomeCategory.execute(
        any<UpdateIncomeCategoryParams>(),
        traceId: traceId,
      ),
    ).thenAnswer(
      (_) async => AppResult.success(updatedFirstCategory),
    );
  });

  IncomeCategoriesBloc buildBloc() {
    return IncomeCategoriesBloc(
      watchIncomeCategories: mockWatchIncomeCategories,
      deleteIncomeCategory: mockDeleteIncomeCategory,
      updateIncomeCategory: mockUpdateIncomeCategory,
    )..customGenerator = mockUidGenerator;
  }

  test('has initial state of IncomeCategoriesState.initial', () {
    final bloc = buildBloc();
    expect(bloc.state, const IncomeCategoriesState());
  });

  group('subscriptionRequested', () {
    blocTest<IncomeCategoriesBloc, IncomeCategoriesState>(
      'emits [loading, loaded] '
      'with correct categories '
      'when watchIncomeCategoriesUseCase returns success',
      build: buildBloc,
      act: (bloc) => bloc.add(
        const IncomeCategoriesEvent.subscriptionRequested(),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <IncomeCategoriesState>[
        const IncomeCategoriesState(status: IncomeCategoriesUIStatus.loading),
        IncomeCategoriesState(
          status: IncomeCategoriesUIStatus.loaded,
          categories: incomeCategories,
        ),
      ],
      verify: (_) {
        verify(
          () => mockWatchIncomeCategories.execute(
            const WatchIncomeCategoriesParams(),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<IncomeCategoriesBloc, IncomeCategoriesState>(
      'emits [loading, loaded] '
      'with correct categories and params '
      'when watchIncomeCategoriesUseCase returns success',
      build: buildBloc,
      act: (bloc) => bloc.add(
        const IncomeCategoriesEvent.subscriptionRequested(query: 'query'),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <IncomeCategoriesState>[
        const IncomeCategoriesState(status: IncomeCategoriesUIStatus.loading),
        IncomeCategoriesState(
          status: IncomeCategoriesUIStatus.loaded,
          categories: incomeCategories,
        ),
      ],
      verify: (_) {
        verify(
          () => mockWatchIncomeCategories.execute(
            const WatchIncomeCategoriesParams(query: 'query'),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<IncomeCategoriesBloc, IncomeCategoriesState>(
      'emits [loading, failure] '
      'when getAllIncomeCategoriesUseCase emits failure',
      setUp: () {
        when(
          () => mockWatchIncomeCategories.execute(
            const WatchIncomeCategoriesParams(),
            traceId: traceId,
          ),
        ).thenAnswer(
          (_) => Stream.value(
            AppResult<List<IncomeCategory>>.failure(AppException.test()),
          ),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const IncomeCategoriesEvent.subscriptionRequested(),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <IncomeCategoriesState>[
        const IncomeCategoriesState(status: IncomeCategoriesUIStatus.loading),
        IncomeCategoriesState(
          status: IncomeCategoriesUIStatus.failure,
          exception: AppException.test(),
        ),
      ],
      verify: (_) {
        verify(
          () => mockWatchIncomeCategories.execute(
            const WatchIncomeCategoriesParams(),
            traceId: traceId,
          ),
        ).called(1);
      },
    );
  });

  group('delete', () {
    blocTest<IncomeCategoriesBloc, IncomeCategoriesState>(
      'emits [new deletingIds, updated notice and deletingIds] '
      'when deleteIncomeCategory returns success',
      seed: () {
        return IncomeCategoriesState(
          status: IncomeCategoriesUIStatus.loaded,
          categories: incomeCategories,
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        IncomeCategoriesEvent.delete(incomeCategories.first),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <IncomeCategoriesState>[
        IncomeCategoriesState(
          status: IncomeCategoriesUIStatus.loaded,
          categories: incomeCategories,
          deletingIds: {incomeCategories.first.id},
        ),
        IncomeCategoriesState(
          status: IncomeCategoriesUIStatus.loaded,
          categories: incomeCategories,
          deletingIds: {},
          notice: IncomeCategoryUINotice.recentlyDeleted(
            category: incomeCategories.first,
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => mockDeleteIncomeCategory.execute(
            DeleteIncomeCategoryParams(category: incomeCategories.first),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<IncomeCategoriesBloc, IncomeCategoriesState>(
      'emits [new deletingIds, '
      'failed notice and updated deletingIds] '
      'when deleteIncomeCategory returns failure',
      setUp: () {
        when(
          () => mockDeleteIncomeCategory.execute(
            DeleteIncomeCategoryParams(category: incomeCategories.first),
            traceId: traceId,
          ),
        ).thenAnswer(
          (_) async => AppResult<Null>.failure(AppException.test()),
        );
      },
      seed: () {
        return IncomeCategoriesState(
          status: IncomeCategoriesUIStatus.loaded,
          categories: incomeCategories,
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        IncomeCategoriesEvent.delete(incomeCategories.first),
      ),
      wait: kDefaultDebounceDuration,
      expect: () => <IncomeCategoriesState>[
        IncomeCategoriesState(
          status: IncomeCategoriesUIStatus.loaded,
          categories: incomeCategories,
          deletingIds: {incomeCategories.first.id},
        ),
        IncomeCategoriesState(
          status: IncomeCategoriesUIStatus.loaded,
          categories: incomeCategories,
          deletingIds: {},
          notice: IncomeCategoryUINotice.deleteFailed(
            category: incomeCategories.first,
            exception: AppException.test(),
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => mockDeleteIncomeCategory.execute(
            DeleteIncomeCategoryParams(
              category: incomeCategories.first,
            ),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<IncomeCategoriesBloc, IncomeCategoriesState>(
      'do nothing when category not found on categories',
      seed: () {
        return const IncomeCategoriesState(
          status: IncomeCategoriesUIStatus.loaded,
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
      'emits [new updatingIds, updated notice and updatingIds] '
      'when updateIncomeCategory returns success',
      seed: () {
        return IncomeCategoriesState(
          status: IncomeCategoriesUIStatus.loaded,
          categories: incomeCategories,
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
          status: IncomeCategoriesUIStatus.loaded,
          categories: incomeCategories,
          updatingIds: {incomeCategories.first.id},
        ),
        IncomeCategoriesState(
          status: IncomeCategoriesUIStatus.loaded,
          categories: incomeCategories,
          updatingIds: {},
          notice: IncomeCategoryUINotice.recentlyUpdated(
            from: incomeCategories.first,
            to: updatedFirstCategory,
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => mockUpdateIncomeCategory.execute(
            UpdateIncomeCategoryParams(
              category: incomeCategories.first,
              name: updatedFirstCategory.name,
            ),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<IncomeCategoriesBloc, IncomeCategoriesState>(
      'emits [new updatingIds, '
      'updateFailure notice and updated updatingIds] '
      'when updateIncomeCategory returns failure',
      setUp: () {
        when(
          () => mockUpdateIncomeCategory.execute(
            UpdateIncomeCategoryParams(
              category: incomeCategories.first,
              name: updatedFirstCategory.name,
            ),
            traceId: traceId,
          ),
        ).thenAnswer(
          (_) async => AppResult<IncomeCategory>.failure(AppException.test()),
        );
      },
      seed: () {
        return IncomeCategoriesState(
          status: IncomeCategoriesUIStatus.loaded,
          categories: incomeCategories,
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
          status: IncomeCategoriesUIStatus.loaded,
          categories: incomeCategories,
          updatingIds: {incomeCategories.first.id},
        ),
        IncomeCategoriesState(
          status: IncomeCategoriesUIStatus.loaded,
          categories: incomeCategories,
          updatingIds: {},
          notice: IncomeCategoryUINotice.updateFailed(
            category: incomeCategories.first,
            exception: AppException.test(),
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => mockUpdateIncomeCategory.execute(
            UpdateIncomeCategoryParams(
              category: incomeCategories.first,
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
          status: IncomeCategoriesUIStatus.loaded,
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
