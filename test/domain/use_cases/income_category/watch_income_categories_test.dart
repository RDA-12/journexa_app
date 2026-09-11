import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/domain/repositories/i_income_category_repository.dart';
import 'package:journexa_app/domain/use_cases/income_category/watch_income_categories.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mocktail/mocktail.dart';

class MockIncomeCategoryRepository extends Mock
    implements IIncomeCategoryRepository {}

void main() {
  const traceId = 'traceId';
  final parent = SystemDefinedAccount.incomeParent;
  final accounts = List.generate(
    5,
    (idx) => Account.sub(
      name: 'income $idx',
      parent: parent,
      currentChildrenCount: idx,
    ),
  );
  final categories = accounts
      .map(
        (it) => IncomeCategory(
          id: it.code.value,
          name: it.name,
          icon: '',
          account: it,
        ),
      )
      .toList();

  late IIncomeCategoryRepository mockIncomeCategoryRepository;
  late WatchIncomeCategoriesUseCase useCase;

  setUp(() {
    mockIncomeCategoryRepository = MockIncomeCategoryRepository();
    when(
      () => mockIncomeCategoryRepository.watch(
        traceId: traceId,
        query: any(named: 'query'),
        isDeleted: any(named: 'isDeleted'),
      ),
    ).thenAnswer((_) => Stream.value(AppResult.success(categories)));

    useCase = WatchIncomeCategoriesUseCase(
      incomeCategoryRepository: mockIncomeCategoryRepository,
    );
  });

  test(
    'calls IncomeCategoryRepository.watch once '
    'with correct args',
    () async {
      final result = useCase.execute(
        const WatchIncomeCategoriesParams(),
        traceId: traceId,
      );
      await result.first;

      verify(
        () => mockIncomeCategoryRepository.watch(
          traceId: traceId,
          isDeleted: false,
        ),
      ).called(1);
    },
  );

  test(
    'calls IncomeCategoryRepository.watch once '
    'with correct args when query provided',
    () async {
      final result = useCase.execute(
        const WatchIncomeCategoriesParams(query: 'query'),
        traceId: traceId,
      );
      await result.first;

      verify(
        () => mockIncomeCategoryRepository.watch(
          traceId: traceId,
          query: 'query',
          isDeleted: false,
        ),
      ).called(1);
    },
  );

  test(
    'emits correct categories when all operations are successful',
    () async {
      final result = useCase.execute(
        const WatchIncomeCategoriesParams(),
        traceId: traceId,
      );

      expect(result, emits(AppResult.success(categories)));
    },
  );

  test(
    'emits failure '
    'when IncomeCategoryRepository.watch emits failure',
    () async {
      when(
        () => mockIncomeCategoryRepository.watch(
          traceId: traceId,
          isDeleted: false,
        ),
      ).thenAnswer((_) => Stream.value(AppResult.failure(AppException.test())));

      final result = useCase.execute(
        const WatchIncomeCategoriesParams(),
        traceId: traceId,
      );

      expect(
        result,
        emits(
          AppResult<List<IncomeCategory>>.failure(AppException.test()),
        ),
      );
    },
  );
}
