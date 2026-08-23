import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/repositories/i_income_category.dart';
import 'package:journexa_app/domain/use_cases/income_category/get_all_income_categories.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mocktail/mocktail.dart';

class MockIncomeCategoryRepository extends Mock
    implements IIncomeCategoryRepository {}

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  const userId = 'userId';
  const traceId = 'traceId';
  const expectedParentCode = '40.0000';
  final parent = Account(
    code: expectedParentCode,
    name: 'revenue',
    type: AccountType.revenue,
    isSystemAccount: true,
  );
  final accounts = List.generate(
    5,
    (idx) => Account(
      code: '40.000${idx + 1}',
      name: 'income $idx',
      type: parent.type,
      parent: parent,
    ),
  );
  final categories = accounts
      .map(
        (it) => IncomeCategory(
          id: it.code,
          name: it.name,
          icon: '',
          account: it,
        ),
      )
      .toList();

  late IAuthRepository mockAuthRepository;
  late IIncomeCategoryRepository mockIncomeCategoryRepository;
  late GetAllIncomeCategoriesUseCase useCase;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    when(
      () => mockAuthRepository.getCurrentUserId(traceId: traceId),
    ).thenAnswer((_) async => const AppResult.success(userId));

    mockIncomeCategoryRepository = MockIncomeCategoryRepository();
    when(
      () => mockIncomeCategoryRepository.getAll(
        userId: userId,
        traceId: traceId,
        query: any(named: 'query'),
      ),
    ).thenAnswer((_) async => AppResult.success(categories));

    useCase = GetAllIncomeCategoriesUseCase(
      authRepository: mockAuthRepository,
      incomeCategoryRepository: mockIncomeCategoryRepository,
    );
  });

  test(
    'calls AuthRepository.getCurrentUserId once '
    'to get current user id',
    () async {
      await useCase.execute(
        const GetAllIncomeCategoriesParams(),
        traceId: traceId,
      );

      verify(
        () => mockAuthRepository.getCurrentUserId(traceId: traceId),
      ).called(1);
    },
  );

  test(
    'calls IncomeCategoryRepository.getAll once '
    'with correct args',
    () async {
      await useCase.execute(
        const GetAllIncomeCategoriesParams(),
        traceId: traceId,
      );

      verify(
        () => mockIncomeCategoryRepository.getAll(
          userId: userId,
          traceId: traceId,
        ),
      ).called(1);
    },
  );

  test(
    'calls IncomeCategoryRepository.getAll once '
    'with correct args when query provided',
    () async {
      await useCase.execute(
        const GetAllIncomeCategoriesParams(query: 'query'),
        traceId: traceId,
      );

      verify(
        () => mockIncomeCategoryRepository.getAll(
          userId: userId,
          traceId: traceId,
          query: 'query',
        ),
      ).called(1);
    },
  );

  test(
    'returns correct categories when all operations are successful',
    () async {
      final result = await useCase.execute(
        const GetAllIncomeCategoriesParams(),
        traceId: traceId,
      );

      expect(result, AppResult.success(categories));
    },
  );

  test(
    'returns failure and not fetch Accounts '
    'when AuthRepository.getCurrentUserId failed',
    () async {
      when(
        () => mockAuthRepository.getCurrentUserId(traceId: traceId),
      ).thenAnswer((_) async => AppResult<String>.failure(AppException.test()));

      final result = await useCase.execute(
        const GetAllIncomeCategoriesParams(),
        traceId: traceId,
      );

      expect(
        result,
        AppResult<List<IncomeCategory>>.failure(
          AppException.test(),
        ),
      );
      verifyZeroInteractions(mockIncomeCategoryRepository);
    },
  );

  test(
    'returns failure '
    'when IncomeCategoryRepository.getAll failed',
    () async {
      when(
        () => mockIncomeCategoryRepository.getAll(
          userId: userId,
          traceId: traceId,
        ),
      ).thenAnswer((_) async => AppResult.failure(AppException.test()));

      final result = await useCase.execute(
        const GetAllIncomeCategoriesParams(),
        traceId: traceId,
      );

      expect(
        result,
        AppResult<List<IncomeCategory>>.failure(AppException.test()),
      );
    },
  );
}
