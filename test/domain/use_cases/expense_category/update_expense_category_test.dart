import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/expense_category.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/repositories/i_expense_category_repository.dart';
import 'package:journexa_app/domain/use_cases/expense_category/update_expense_category.dart';
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
  final params = UpdateExpenseCategoryParams(
    category: category,
    name: 'new name',
  );
  final updatedCategory = category.copyWith(
    name: params.name!,
    account: category.account.copyWith(name: params.name!),
  );

  late IAuthRepository mockAuthRepository;
  late IExpenseCategoryRepository mockExpenseCategoryRepository;
  late UpdateExpenseCategoryUseCase useCase;

  setUpAll(() {
    registerFallbackValue(updatedCategory);
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    when(
      () => mockAuthRepository.getCurrentUserId(traceId: traceId),
    ).thenAnswer((_) async => const AppResult.success(userId));

    mockExpenseCategoryRepository = MockExpenseCategoryRepository();
    when(
      () => mockExpenseCategoryRepository.update(
        userId: userId,
        updatedCategory: updatedCategory,
        traceId: traceId,
      ),
    ).thenAnswer((_) async => const AppResult.success(null));

    useCase = UpdateExpenseCategoryUseCase(
      authRepository: mockAuthRepository,
      expenseCategoryRepository: mockExpenseCategoryRepository,
    );
  });

  test(
    'calls AuthRepository.getCurrentUserId '
    'once to get current user id',
    () async {
      await useCase.execute(params, traceId: traceId);

      verify(
        () => mockAuthRepository.getCurrentUserId(traceId: traceId),
      ).called(1);
    },
  );

  test(
    'calls ExpenseCategoryRepository.update once '
    'to save updated category',
    () async {
      await useCase.execute(params, traceId: traceId);

      verify(
        () => mockExpenseCategoryRepository.update(
          userId: userId,
          updatedCategory: updatedCategory,
          traceId: traceId,
        ),
      ).called(1);
    },
  );

  test(
    'returns success with updated ExpenseCategory '
    'when all operations succeeded',
    () async {
      final result = await useCase.execute(params, traceId: traceId);

      expect(result, AppResult.success(updatedCategory));
    },
  );

  test(
    'returns failure and not saving ExpenseCategory '
    'when AuthRepository.getCurrentUserId failed',
    () async {
      when(
        () => mockAuthRepository.getCurrentUserId(
          traceId: traceId,
        ),
      ).thenAnswer((_) async => AppResult<String>.failure(AppException.test()));

      final result = await useCase.execute(params, traceId: traceId);

      expect(result, AppResult<ExpenseCategory>.failure(AppException.test()));
      verifyZeroInteractions(mockExpenseCategoryRepository);
    },
  );

  test(
    'returns failure '
    'when ExpenseCategoryRepository.update failed',
    () async {
      when(
        () => mockExpenseCategoryRepository.update(
          userId: userId,
          updatedCategory: updatedCategory,
          traceId: traceId,
        ),
      ).thenAnswer((_) async => AppResult<Null>.failure(AppException.test()));

      final result = await useCase.execute(params, traceId: traceId);

      expect(result, AppResult<ExpenseCategory>.failure(AppException.test()));
    },
  );
}
