import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/expense_category.dart';
import 'package:journexa_app/domain/repositories/i_account_repository.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/repositories/i_expense_category.dart';
import 'package:journexa_app/domain/use_cases/expense_category/add_expense_category.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

class MockAccountRepository extends Mock implements IAccountRepository {}

class MockExpenseCategoryRepository extends Mock
    implements IExpenseCategoryRepository {}

class MockUidGenerator extends Mock implements UidGenerator {}

void main() {
  const traceId = 'trace';
  const userId = 'userId';
  const currentChildrenCount = 10;
  const params = AddExpenseCategoryParams(
    name: 'rent',
  );
  final expectedCategory = ExpenseCategory(
    id: 'id',
    name: params.name,
    icon: 'icon',
    account: Account.user(
      parent: SystemDefinedAccount.rootExpense,
      name: params.name,
      currentChildrenCount: currentChildrenCount,
    ),
  );

  late IAuthRepository mockAuthRepository;
  late IAccountRepository mockAccountRepository;
  late IExpenseCategoryRepository mockExpenseCategoryRepository;
  late UidGenerator mockUidGenerator;
  late AddExpenseCategoryUseCase useCase;

  setUpAll(() {
    registerFallbackValue(Account.test());
    registerFallbackValue(ExpenseCategory.test());
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    when(
      () => mockAuthRepository.getCurrentUserId(traceId: traceId),
    ).thenAnswer(
      (_) async => const AppResult.success(userId),
    );

    mockAccountRepository = MockAccountRepository();
    when(
      () => mockAccountRepository.getChildrenCountByParentCode(
        userId: any<String>(named: 'userId'),
        parentCode: any<String>(named: 'parentCode'),
        traceId: traceId,
      ),
    ).thenAnswer(
      (_) async => const AppResult.success(currentChildrenCount),
    );

    mockExpenseCategoryRepository = MockExpenseCategoryRepository();
    when(
      () => mockExpenseCategoryRepository.save(
        userId: any<String>(named: 'userId'),
        category: any<ExpenseCategory>(named: 'category'),
        traceId: traceId,
      ),
    ).thenAnswer(
      (_) async => const AppResult.success(null),
    );

    mockUidGenerator = MockUidGenerator();
    when(mockUidGenerator.generateUid).thenReturn(expectedCategory.id);

    useCase = AddExpenseCategoryUseCase(
      authRepository: mockAuthRepository,
      accountRepository: mockAccountRepository,
      expenseCategoryRepository: mockExpenseCategoryRepository,
    )..customGenerator = mockUidGenerator;
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
    'calls AccountRepository.getChildrenCountByParentCode once '
    'to get current expense account children count',
    () async {
      await useCase.execute(params, traceId: traceId);

      verify(
        () => mockAccountRepository.getChildrenCountByParentCode(
          userId: userId,
          parentCode: '50.0000',
          traceId: traceId,
        ),
      ).called(1);
    },
  );

  test(
    'calls ExpenseCategoryRepository.save once '
    'with correct userId and ExpenseCategory',
    () async {
      await useCase.execute(params, traceId: traceId);

      verify(
        () => mockExpenseCategoryRepository.save(
          userId: userId,
          category: expectedCategory,
          traceId: traceId,
        ),
      ).called(1);
    },
  );

  test(
    'returns AppResult.success when all operations are successful',
    () async {
      final result = await useCase.execute(params, traceId: traceId);

      expect(result, const AppResult<Null>.success(null));
    },
  );

  test(
    'returns AppResult.failure and not save Account '
    'when AuthRepository.getCurrentUserId failed',
    () async {
      when(
        () => mockAuthRepository.getCurrentUserId(traceId: traceId),
      ).thenAnswer(
        (_) async => AppResult.failure(AppException.test()),
      );

      final result = await useCase.execute(params, traceId: traceId);

      expect(result, AppResult<Null>.failure(AppException.test()));
      verifyZeroInteractions(mockAccountRepository);
      verifyZeroInteractions(mockExpenseCategoryRepository);
    },
  );

  test(
    'return AppResult.failure and not save Account '
    'when AccountRepository.getChildrenCountByParentCode failed',
    () async {
      when(
        () => mockAccountRepository.getChildrenCountByParentCode(
          userId: userId,
          parentCode: any<String>(named: 'parentCode'),
          traceId: traceId,
        ),
      ).thenAnswer(
        (_) async => AppResult<int>.failure(AppException.test()),
      );

      final result = await useCase.execute(params, traceId: traceId);

      expect(result, AppResult<Null>.failure(AppException.test()));
      verify(
        () => mockAccountRepository.getChildrenCountByParentCode(
          userId: userId,
          parentCode: '50.0000',
          traceId: traceId,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockAccountRepository);
      verifyZeroInteractions(mockExpenseCategoryRepository);
    },
  );

  test(
    'return AppResult.failure '
    'when ExpenseCategoryRepository.save failed',
    () async {
      when(
        () => mockExpenseCategoryRepository.save(
          userId: userId,
          category: any<ExpenseCategory>(named: 'category'),
          traceId: traceId,
        ),
      ).thenAnswer(
        (_) async => AppResult.failure(AppException.test()),
      );

      final result = await useCase.execute(params, traceId: traceId);

      expect(result, AppResult<Null>.failure(AppException.test()));
      verify(
        () => mockAccountRepository.getChildrenCountByParentCode(
          userId: userId,
          parentCode: '50.0000',
          traceId: traceId,
        ),
      ).called(1);
      verify(
        () => mockExpenseCategoryRepository.save(
          userId: userId,
          category: expectedCategory,
          traceId: traceId,
        ),
      ).called(1);
    },
  );
}
