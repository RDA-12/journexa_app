import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/domain/repositories/i_income_category_repository.dart';
import 'package:journexa_app/domain/use_cases/income_category/update_income_category.dart';
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
  final params = UpdateIncomeCategoryParams(
    category: category,
    name: 'new name',
  );
  final updatedCategory = category.copyWith(
    name: params.name!,
    account: category.account.copyWith(name: params.name!),
  );

  late IIncomeCategoryRepository mockIncomeCategoryRepository;
  late UpdateIncomeCategoryUseCase useCase;

  setUpAll(() {
    registerFallbackValue(updatedCategory);
  });

  setUp(() {
    mockIncomeCategoryRepository = MockIncomeCategoryRepository();
    when(
      () => mockIncomeCategoryRepository.update(
        updatedCategory: updatedCategory,
        traceId: traceId,
      ),
    ).thenAnswer((_) async => const AppResult.success(null));

    useCase = UpdateIncomeCategoryUseCase(
      incomeCategoryRepository: mockIncomeCategoryRepository,
    );
  });

  test(
    'calls IncomeCategoryRepository.update once '
    'to save updated category',
    () async {
      await useCase.execute(params, traceId: traceId);

      verify(
        () => mockIncomeCategoryRepository.update(
          updatedCategory: updatedCategory,
          traceId: traceId,
        ),
      ).called(1);
    },
  );

  test(
    'returns success with updated IncomeCategory '
    'when all operations succeeded',
    () async {
      final result = await useCase.execute(params, traceId: traceId);

      expect(result, AppResult.success(updatedCategory));
    },
  );

  test(
    'returns failure '
    'when IncomeCategoryRepository.update failed',
    () async {
      when(
        () => mockIncomeCategoryRepository.update(
          updatedCategory: updatedCategory,
          traceId: traceId,
        ),
      ).thenAnswer((_) async => AppResult<Null>.failure(AppException.test()));

      final result = await useCase.execute(params, traceId: traceId);

      expect(result, AppResult<IncomeCategory>.failure(AppException.test()));
    },
  );
}
