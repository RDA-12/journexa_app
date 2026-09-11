import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/domain/repositories/i_income_category_repository.dart';
import 'package:journexa_app/domain/use_cases/income_category/delete_income_category.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mocktail/mocktail.dart';

class MockIncomeCategoryRepository extends Mock
    implements IIncomeCategoryRepository {}

void main() {
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

  late IIncomeCategoryRepository mockIncomeCategoryRepository;
  late DeleteIncomeCategoryUseCase useCase;

  setUp(() {
    mockIncomeCategoryRepository = MockIncomeCategoryRepository();
    when(
      () => mockIncomeCategoryRepository.delete(
        category: params.category,
        traceId: traceId,
      ),
    ).thenAnswer((_) async => const AppResult.success(null));

    useCase = DeleteIncomeCategoryUseCase(
      incomeCategoryRepository: mockIncomeCategoryRepository,
    );
  });

  test(
    'calls IncomeCategoryRepository.delete once '
    'with correct args',
    () async {
      await useCase.execute(params, traceId: traceId);

      verify(
        () => mockIncomeCategoryRepository.delete(
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
    'returns failure when IncomeCategoryRepository.delete failed',
    () async {
      when(
        () => mockIncomeCategoryRepository.delete(
          category: params.category,
          traceId: traceId,
        ),
      ).thenAnswer((_) async => AppResult.failure(AppException.test()));

      final result = await useCase.execute(params, traceId: traceId);

      expect(result, AppResult<Null>.failure(AppException.test()));
    },
  );
}
