import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/repositories/i_account_repository.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/use_cases/income_category/get_all_income_categories.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mocktail/mocktail.dart';

class MockAccountRepository extends Mock implements IAccountRepository {}

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

  late IAuthRepository mockAuthRepository;
  late IAccountRepository mockAccountRepository;
  late GetAllIncomeCategoriesUseCase useCase;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    when(
      () => mockAuthRepository.getCurrentUserId(traceId: traceId),
    ).thenAnswer((_) async => const AppResult.success(userId));

    mockAccountRepository = MockAccountRepository();
    when(
      () => mockAccountRepository.getByParentCode(
        userId: userId,
        parentCode: expectedParentCode,
        traceId: traceId,
        query: any(named: 'query'),
      ),
    ).thenAnswer((_) async => AppResult.success(accounts));

    useCase = GetAllIncomeCategoriesUseCase(
      authRepository: mockAuthRepository,
      accountRepository: mockAccountRepository,
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
    'calls AccountRepository.getByParentCode once '
    'with correct args',
    () async {
      await useCase.execute(
        const GetAllIncomeCategoriesParams(),
        traceId: traceId,
      );

      verify(
        () => mockAccountRepository.getByParentCode(
          userId: userId,
          parentCode: expectedParentCode,
          traceId: traceId,
        ),
      ).called(1);
    },
  );

  test(
    'calls AccountRepository.getByParentCode once '
    'with correct args when query provided',
    () async {
      await useCase.execute(
        const GetAllIncomeCategoriesParams(query: 'query'),
        traceId: traceId,
      );

      verify(
        () => mockAccountRepository.getByParentCode(
          userId: userId,
          parentCode: expectedParentCode,
          traceId: traceId,
          query: 'query',
        ),
      ).called(1);
    },
  );

  test(
    'returns correct AccountBalances when all operations are successful',
    () async {
      final result = await useCase.execute(
        const GetAllIncomeCategoriesParams(),
        traceId: traceId,
      );

      expect(result, AppResult.success(accounts));
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
        AppResult<List<Account>>.failure(
          AppException.test(),
        ),
      );
      verifyZeroInteractions(mockAccountRepository);
    },
  );

  test(
    'returns failure '
    'when AccountRepository.getByParentCode failed',
    () async {
      when(
        () => mockAccountRepository.getByParentCode(
          userId: userId,
          parentCode: expectedParentCode,
          traceId: traceId,
        ),
      ).thenAnswer((_) async => AppResult.failure(AppException.test()));

      final result = await useCase.execute(
        const GetAllIncomeCategoriesParams(),
        traceId: traceId,
      );

      expect(result, AppResult<List<Account>>.failure(AppException.test()));
    },
  );
}
