import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/use_cases/expense_category/add_expense_category.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';
import 'package:journexa_app/ui/expense_categories/bloc/add_expense_category_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockAddExpenseCategoryUseCase extends Mock
    implements AddExpenseCategoryUseCase {}

class MockUidGenerator extends Mock implements UidGenerator {}

void main() {
  const traceId = 'trace';
  const params = AddExpenseCategoryParams(name: 'Test');

  late AddExpenseCategoryUseCase mockAddExpenseCategory;
  late UidGenerator mockUidGenerator;

  setUpAll(() {
    registerFallbackValue(params);
  });

  setUp(() {
    mockAddExpenseCategory = MockAddExpenseCategoryUseCase();
    when(
      () => mockAddExpenseCategory.execute(
        any<AddExpenseCategoryParams>(),
        traceId: traceId,
      ),
    ).thenAnswer((_) async => const AppResult.success(null));
    mockUidGenerator = MockUidGenerator();
    when(() => mockUidGenerator.generateUid()).thenReturn(traceId);
  });

  AddExpenseCategoryBloc buildBloc() {
    return AddExpenseCategoryBloc(
      addExpenseCategory: mockAddExpenseCategory,
    )..customGenerator = mockUidGenerator;
  }

  test('Initial state should be AddExpenseCategoryState.initial', () {
    expect(buildBloc().state, const AddExpenseCategoryState.initial());
  });

  group('submit', () {
    blocTest<AddExpenseCategoryBloc, AddExpenseCategoryState>(
      'emits [AddExpenseCategoryState.loading, AddExpenseCategoryState.added] '
      'when add expense category succeeded',
      build: buildBloc,
      act: (bloc) =>
          bloc.add(AddExpenseCategoryEvent.submit(name: params.name)),
      expect: () => const <AddExpenseCategoryState>[
        AddExpenseCategoryState.loading(),
        AddExpenseCategoryState.added(),
      ],
      verify: (_) {
        verify(() => mockUidGenerator.generateUid()).called(1);
        verify(
          () => mockAddExpenseCategory.execute(params, traceId: traceId),
        ).called(1);
      },
    );

    blocTest<AddExpenseCategoryBloc, AddExpenseCategoryState>(
      'emits [AddExpenseCategoryState.loading, '
      'AddExpenseCategoryState.failure] '
      'when add expense category failed',
      setUp: () {
        when(
          () => mockAddExpenseCategory.execute(params, traceId: traceId),
        ).thenAnswer(
          (_) async => AppResult<Null>.failure(AppException.test()),
        );
      },
      build: buildBloc,
      act: (bloc) =>
          bloc.add(AddExpenseCategoryEvent.submit(name: params.name)),
      expect: () => <AddExpenseCategoryState>[
        const AddExpenseCategoryState.loading(),
        AddExpenseCategoryState.failure(
          AppException.test(),
          name: params.name,
        ),
      ],
      verify: (_) {
        verify(() => mockUidGenerator.generateUid()).called(1);
        verify(
          () => mockAddExpenseCategory.execute(params, traceId: traceId),
        ).called(1);
      },
    );
  });
}
