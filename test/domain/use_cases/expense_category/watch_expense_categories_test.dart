import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/expense_category.dart';
import 'package:journexa_app/domain/repositories/i_expense_category_repository.dart';
import 'package:journexa_app/domain/use_cases/expense_category/watch_expense_categories.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mocktail/mocktail.dart';

class MockExpenseCategoryRepository extends Mock
    implements IExpenseCategoryRepository {}

void main() {
  const traceId = 'traceId';
  final parent = SystemDefinedAccount.expenseParent;
  final accounts = List.generate(
    5,
    (idx) => Account.sub(
      name: 'expense $idx',
      parent: parent,
      currentChildrenCount: idx,
    ),
  );
  final categories = accounts
      .map(
        (it) => ExpenseCategory(
          id: it.code.value,
          name: it.name,
          icon: '',
          account: it,
        ),
      )
      .toList();

  late IExpenseCategoryRepository mockExpenseCategoryRepository;
  late WatchExpenseCategoriesUseCase useCase;

  setUp(() {
    mockExpenseCategoryRepository = MockExpenseCategoryRepository();
    when(
      () => mockExpenseCategoryRepository.watch(
        traceId: traceId,
        query: any(named: 'query'),
        isDeleted: any(named: 'isDeleted'),
      ),
    ).thenAnswer((_) => Stream.value(AppResult.success(categories)));

    useCase = WatchExpenseCategoriesUseCase(
      expenseCategoryRepository: mockExpenseCategoryRepository,
    );
  });

  test(
    'calls ExpenseCategoryRepository.watch once '
    'with correct args',
    () async {
      final result = useCase.execute(
        const WatchExpenseCategoriesParams(),
        traceId: traceId,
      );
      await result.first;

      verify(
        () => mockExpenseCategoryRepository.watch(
          traceId: traceId,
          isDeleted: false,
        ),
      ).called(1);
    },
  );

  test(
    'calls ExpenseCategoryRepository.watch once '
    'with correct args when query provided',
    () async {
      final result = useCase.execute(
        const WatchExpenseCategoriesParams(query: 'query'),
        traceId: traceId,
      );
      await result.first;

      verify(
        () => mockExpenseCategoryRepository.watch(
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
        const WatchExpenseCategoriesParams(),
        traceId: traceId,
      );

      expect(result, emits(AppResult.success(categories)));
    },
  );

  test(
    'emits failure '
    'when ExpenseCategoryRepository.watch emits failure',
    () async {
      when(
        () => mockExpenseCategoryRepository.watch(
          traceId: traceId,
          isDeleted: false,
        ),
      ).thenAnswer((_) => Stream.value(AppResult.failure(AppException.test())));

      final result = useCase.execute(
        const WatchExpenseCategoriesParams(),
        traceId: traceId,
      );

      expect(
        result,
        emits(
          AppResult<List<ExpenseCategory>>.failure(AppException.test()),
        ),
      );
    },
  );
}
