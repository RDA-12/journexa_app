import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/repositories/i_income_category_repository.dart';
import 'package:journexa_app/domain/use_cases/income_category/delete_income_category.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

class MockIncomeCategoryRepository extends Mock
    implements IIncomeCategoryRepository {}

void main() {
  const userId = 'userId';
  const traceId = 'traceId';
  final category = IncomeCategory(
    id: 'id',
    name: 'salary',
    icon: 'icon',
    account: Account.user(
      parent: SystemDefinedAccount.rootRevenue,
      currentChildrenCount: 0,
      name: 'salary',
    ),
  );
  final params = DeleteIncomeCategoryParams(category: category);

  late IAuthRepository mockAuthRepository;
  late IIncomeCategoryRepository mockIncomeCategoryRepository;
  late DeleteIncomeCategoryUseCase useCase;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    when(
      () => mockAuthRepository.getCurrentUserId(traceId: traceId),
    ).thenAnswer((_) async => const AppResult.success(userId));

    mockIncomeCategoryRepository = MockIncomeCategoryRepository();
    when(
      () => mockIncomeCategoryRepository.delete(
        userId: userId,
        category: params.category,
        traceId: traceId,
      ),
    ).thenAnswer((_) async => const AppResult.success(null));

    useCase = DeleteIncomeCategoryUseCase(
      authRepository: mockAuthRepository,
      incomeCategoryRepository: mockIncomeCategoryRepository,
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
    'calls IncomeCategoryRepository.delete once '
    'with correct args',
    () async {
      await useCase.execute(params, traceId: traceId);

      verify(
        () => mockIncomeCategoryRepository.delete(
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
    'and not call IncomeCategoryRepository.delete',
    () async {
      when(
        () => mockAuthRepository.getCurrentUserId(traceId: traceId),
      ).thenAnswer((_) async => AppResult.failure(AppException.test()));

      final result = await useCase.execute(params, traceId: traceId);

      expect(result, AppResult<Null>.failure(AppException.test()));
      verifyZeroInteractions(mockIncomeCategoryRepository);
    },
  );

  test(
    'returns failure when IncomeCategoryRepository.delete failed',
    () async {
      when(
        () => mockIncomeCategoryRepository.delete(
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
