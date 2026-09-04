import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/expense_category.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/repositories/i_expense_category_repository.dart';
import 'package:journexa_app/domain/use_cases/expense_category/delete_expense_category.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

class MockExpenseCategoryRepository extends Mock
    implements IExpenseCategoryRepository {}

void main() {
  const userId = 'userId';
  const traceId = 'traceId';
  final category = ExpenseCategory(
    id: 'id',
    name: 'rent',
    icon: 'icon',
    account: Account.user(
      parent: SystemDefinedAccount.rootExpense,
      currentChildrenCount: 0,
      name: 'rent',
    ),
  );
  final params = DeleteExpenseCategoryParams(category: category);

  late IAuthRepository mockAuthRepository;
  late IExpenseCategoryRepository mockExpenseCategoryRepository;
  late DeleteExpenseCategoryUseCase useCase;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    when(
      () => mockAuthRepository.getCurrentUserId(traceId: traceId),
    ).thenAnswer((_) async => const AppResult.success(userId));

    mockExpenseCategoryRepository = MockExpenseCategoryRepository();
    when(
      () => mockExpenseCategoryRepository.delete(
        userId: userId,
        category: params.category,
        traceId: traceId,
      ),
    ).thenAnswer((_) async => const AppResult.success(null));

    useCase = DeleteExpenseCategoryUseCase(
      authRepository: mockAuthRepository,
      expenseCategoryRepository: mockExpenseCategoryRepository,
    );
  });

  test(
    'calls AuthRepository.getCurrentUserId once '
    'to get current user id',
    () async {
      await useCase.execute(params, traceId: traceId);

      verify(
        () => mockAuthRepository.getCurrentUserId(traceId: traceId),
      ).called(1);
    },
  );

  test(
    'calls ExpenseCategoryRepository.delete once '
    'with correct args',
    () async {
      await useCase.execute(params, traceId: traceId);

      verify(
        () => mockExpenseCategoryRepository.delete(
          userId: userId,
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
    'returns failure when AuthRepository.getCurrentUserId failed '
    'and not call ExpenseCategoryRepository.delete',
    () async {
      when(
        () => mockAuthRepository.getCurrentUserId(traceId: traceId),
      ).thenAnswer((_) async => AppResult.failure(AppException.test()));

      final result = await useCase.execute(params, traceId: traceId);

      expect(result, AppResult<Null>.failure(AppException.test()));
      verifyZeroInteractions(mockExpenseCategoryRepository);
    },
  );

  test(
    'returns failure when ExpenseCategoryRepository.delete failed',
    () async {
      when(
        () => mockExpenseCategoryRepository.delete(
          userId: userId,
          category: params.category,
          traceId: traceId,
        ),
      ).thenAnswer((_) async => AppResult.failure(AppException.test()));

      final result = await useCase.execute(params, traceId: traceId);

      expect(result, AppResult<Null>.failure(AppException.test()));
    },
  );
}
