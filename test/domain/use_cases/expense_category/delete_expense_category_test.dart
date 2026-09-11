import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/expense_category.dart';
import 'package:journexa_app/domain/repositories/i_expense_category_repository.dart';
import 'package:journexa_app/domain/use_cases/expense_category/delete_expense_category.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mocktail/mocktail.dart';

class MockExpenseCategoryRepository extends Mock
    implements IExpenseCategoryRepository {}

void main() {
  const traceId = 'traceId';
  final category = ExpenseCategory(
    id: 'id',
    name: 'rent',
    icon: 'icon',
    account: Account.sub(
      parent: SystemDefinedAccount.expenseParent,
      currentChildrenCount: 0,
      name: 'rent',
    ),
  );
  final params = DeleteExpenseCategoryParams(category: category);

  late IExpenseCategoryRepository mockExpenseCategoryRepository;
  late DeleteExpenseCategoryUseCase useCase;

  setUp(() {
    mockExpenseCategoryRepository = MockExpenseCategoryRepository();
    when(
      () => mockExpenseCategoryRepository.delete(
        category: params.category,
        traceId: traceId,
      ),
    ).thenAnswer((_) async => const AppResult.success(null));

    useCase = DeleteExpenseCategoryUseCase(
      expenseCategoryRepository: mockExpenseCategoryRepository,
    );
  });

  test(
    'calls ExpenseCategoryRepository.delete once '
    'with correct args',
    () async {
      await useCase.execute(params, traceId: traceId);

      verify(
        () => mockExpenseCategoryRepository.delete(
          category: params.category,
          traceId: traceId,
        ),
      );
    },
  );

  test('returns success when all operations are succeeded', () async {
    final result = await useCase.execute(params, traceId: traceId);

    expect(result, const AppResult.success(null));
  });

  test(
    'returns failure when ExpenseCategoryRepository.delete failed',
    () async {
      when(
        () => mockExpenseCategoryRepository.delete(
          category: params.category,
          traceId: traceId,
        ),
      ).thenAnswer((_) async => AppResult.failure(AppException.test()));

      final result = await useCase.execute(params, traceId: traceId);

      expect(result, AppResult<Null>.failure(AppException.test()));
    },
  );
}
