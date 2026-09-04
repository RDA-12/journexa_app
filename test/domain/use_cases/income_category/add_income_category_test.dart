import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/domain/repositories/i_account_repository.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/repositories/i_income_category_repository.dart';
import 'package:journexa_app/domain/use_cases/income_category/add_income_category.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

class MockAccountRepository extends Mock implements IAccountRepository {}

class MockIncomeCategoryRepository extends Mock
    implements IIncomeCategoryRepository {}

class MockUidGenerator extends Mock implements UidGenerator {}

void main() {
  const traceId = 'trace';
  const userId = 'userId';
  const currentChildrenCount = 10;
  const params = AddIncomeCategoryParams(
    name: 'salary',
  );
  final expectedCategory = IncomeCategory(
    id: 'id',
    name: params.name,
    icon: 'icon',
    account: Account.user(
      parent: SystemDefinedAccount.rootRevenue,
      name: params.name,
      currentChildrenCount: currentChildrenCount,
    ),
  );

  late IAuthRepository mockAuthRepository;
  late IAccountRepository mockAccountRepository;
  late IIncomeCategoryRepository mockIncomeCategoryRepository;
  late UidGenerator mockUidGenerator;
  late AddIncomeCategoryUseCase useCase;

  setUpAll(() {
    registerFallbackValue(Account.test());
    registerFallbackValue(IncomeCategory.test());
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

    mockIncomeCategoryRepository = MockIncomeCategoryRepository();
    when(
      () => mockIncomeCategoryRepository.save(
        userId: any<String>(named: 'userId'),
        category: any<IncomeCategory>(named: 'category'),
        traceId: traceId,
      ),
    ).thenAnswer(
      (_) async => const AppResult.success(null),
    );

    mockUidGenerator = MockUidGenerator();
    when(mockUidGenerator.generateUid).thenReturn(expectedCategory.id);

    useCase = AddIncomeCategoryUseCase(
      authRepository: mockAuthRepository,
      accountRepository: mockAccountRepository,
      incomeCategoryRepository: mockIncomeCategoryRepository,
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
    'to get current asset account children count',
    () async {
      await useCase.execute(params, traceId: traceId);

      verify(
        () => mockAccountRepository.getChildrenCountByParentCode(
          userId: userId,
          parentCode: '40.0000',
          traceId: traceId,
        ),
      ).called(1);
    },
  );

  test(
    'calls IncomeCategoryRepository.save once '
    'with correct userId and IncomeCategory',
    () async {
      await useCase.execute(params, traceId: traceId);

      verify(
        () => mockIncomeCategoryRepository.save(
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
      verifyZeroInteractions(mockIncomeCategoryRepository);
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
          parentCode: '40.0000',
          traceId: traceId,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockAccountRepository);
      verifyZeroInteractions(mockIncomeCategoryRepository);
    },
  );

  test(
    'return AppResult.failure '
    'when IncomeCategoryRepository.save failed',
    () async {
      when(
        () => mockIncomeCategoryRepository.save(
          userId: userId,
          category: any<IncomeCategory>(named: 'category'),
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
          parentCode: '40.0000',
          traceId: traceId,
        ),
      ).called(1);
      verify(
        () => mockIncomeCategoryRepository.save(
          userId: userId,
          category: expectedCategory,
          traceId: traceId,
        ),
      ).called(1);
    },
  );
}
