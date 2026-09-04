import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/repositories/i_income_category.dart';
import 'package:journexa_app/domain/use_cases/income_category/watch_income_categories.dart';
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
  late WatchIncomeCategoriesUseCase useCase;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    when(
      () => mockAuthRepository.getCurrentUserId(traceId: traceId),
    ).thenAnswer((_) async => const AppResult.success(userId));

    mockIncomeCategoryRepository = MockIncomeCategoryRepository();
    when(
      () => mockIncomeCategoryRepository.watch(
        userId: userId,
        traceId: traceId,
        query: any(named: 'query'),
        isDeleted: any(named: 'isDeleted'),
      ),
    ).thenAnswer((_) => Stream.value(AppResult.success(categories)));

    useCase = WatchIncomeCategoriesUseCase(
      authRepository: mockAuthRepository,
      incomeCategoryRepository: mockIncomeCategoryRepository,
    );
  });

  test(
    'calls AuthRepository.getCurrentUserId once '
    'to get current user id',
    () async {
      final result = useCase.execute(
        const WatchIncomeCategoriesParams(),
        traceId: traceId,
      );
      await result.first;

      verify(
        () => mockAuthRepository.getCurrentUserId(traceId: traceId),
      ).called(1);
    },
  );

  test(
    'calls IncomeCategoryRepository.watch once '
    'with correct args',
    () async {
      final result = useCase.execute(
        const WatchIncomeCategoriesParams(),
        traceId: traceId,
      );
      await result.first;

      verify(
        () => mockIncomeCategoryRepository.watch(
          userId: userId,
          traceId: traceId,
          isDeleted: false,
        ),
      ).called(1);
    },
  );

  test(
    'calls IncomeCategoryRepository.watch once '
    'with correct args when query provided',
    () async {
      final result = useCase.execute(
        const WatchIncomeCategoriesParams(query: 'query'),
        traceId: traceId,
      );
      await result.first;

      verify(
        () => mockIncomeCategoryRepository.watch(
          userId: userId,
          traceId: traceId,
          query: 'query',
          isDeleted: false,
        ),
      ).called(1);
    },
  );

  test(
    'emits correct categories when all operations are successful',
    () async {
      final result = useCase.execute(
        const WatchIncomeCategoriesParams(),
        traceId: traceId,
      );

      expect(result, emits(AppResult.success(categories)));
    },
  );

  test(
    'emits failure and not fetch Accounts '
    'when AuthRepository.getCurrentUserId failed',
    () async {
      when(
        () => mockAuthRepository.getCurrentUserId(traceId: traceId),
      ).thenAnswer((_) async => AppResult<String>.failure(AppException.test()));

      final result = useCase.execute(
        const WatchIncomeCategoriesParams(),
        traceId: traceId,
      );

      expect(
        result,
        emits(
          AppResult<List<IncomeCategory>>.failure(
            AppException.test(),
          ),
        ),
      );
      verifyZeroInteractions(mockIncomeCategoryRepository);
    },
  );

  test(
    'emits failure '
    'when IncomeCategoryRepository.watch emits failure',
    () async {
      when(
        () => mockIncomeCategoryRepository.watch(
          userId: userId,
          traceId: traceId,
          isDeleted: false,
        ),
      ).thenAnswer((_) => Stream.value(AppResult.failure(AppException.test())));

      final result = useCase.execute(
        const WatchIncomeCategoriesParams(),
        traceId: traceId,
      );

      expect(
        result,
        emits(
          AppResult<List<IncomeCategory>>.failure(AppException.test()),
        ),
      );
    },
  );
}
