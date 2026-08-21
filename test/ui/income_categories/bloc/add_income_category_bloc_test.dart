import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/use_cases/account/add_income_category.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';
import 'package:journexa_app/ui/income_categories/bloc/add_income_category_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockAddIncomeCategoryUseCase extends Mock
    implements AddIncomeCategoryUseCase {}

class MockUidGenerator extends Mock implements UidGenerator {}

void main() {
  const traceId = 'trace';
  const params = AddIncomeCategoryParams(name: 'Test');

  late AddIncomeCategoryUseCase mockAddIncomeCategory;
  late UidGenerator mockUidGenerator;

  setUpAll(() {
    registerFallbackValue(params);
  });

  setUp(() {
    mockAddIncomeCategory = MockAddIncomeCategoryUseCase();
    when(
      () => mockAddIncomeCategory.execute(
        any<AddIncomeCategoryParams>(),
        traceId: traceId,
      ),
    ).thenAnswer((_) async => const AppResult.success(null));
    mockUidGenerator = MockUidGenerator();
    when(() => mockUidGenerator.generateUid()).thenReturn(traceId);
  });

  AddIncomeCategoryBloc buildBloc() {
    return AddIncomeCategoryBloc(
      addIncomeCategory: mockAddIncomeCategory,
    )..customGenerator = mockUidGenerator;
  }

  test('Initial state should be AddIncomeCategoryState.initial', () {
    expect(buildBloc().state, const AddIncomeCategoryState.initial());
  });

  group('submit', () {
    blocTest<AddIncomeCategoryBloc, AddIncomeCategoryState>(
      'emits [AddIncomeCategoryState.loading, AddIncomeCategoryState.added] '
      'when add wallet succeeded',
      build: buildBloc,
      act: (bloc) => bloc.add(AddIncomeCategoryEvent.submit(name: params.name)),
      expect: () => const <AddIncomeCategoryState>[
        AddIncomeCategoryState.loading(),
        AddIncomeCategoryState.added(),
      ],
      verify: (_) {
        verify(() => mockUidGenerator.generateUid()).called(1);
        verify(
          () => mockAddIncomeCategory.execute(params, traceId: traceId),
        ).called(1);
      },
    );

    blocTest<AddIncomeCategoryBloc, AddIncomeCategoryState>(
      'emits [AddIncomeCategoryState.loading, AddIncomeCategoryState.failure] '
      'when add wallet failed',
      setUp: () {
        when(
          () => mockAddIncomeCategory.execute(params, traceId: traceId),
        ).thenAnswer(
          (_) async => AppResult<Null>.failure(AppException.test()),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(AddIncomeCategoryEvent.submit(name: params.name)),
      expect: () => <AddIncomeCategoryState>[
        const AddIncomeCategoryState.loading(),
        AddIncomeCategoryState.failure(AppException.test()),
      ],
      verify: (_) {
        verify(() => mockUidGenerator.generateUid()).called(1);
        verify(
          () => mockAddIncomeCategory.execute(params, traceId: traceId),
        ).called(1);
      },
    );
  });
}
