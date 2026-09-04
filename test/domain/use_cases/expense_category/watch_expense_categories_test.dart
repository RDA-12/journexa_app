import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/expense_category.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/repositories/i_expense_category.dart';
import 'package:journexa_app/domain/use_cases/expense_category/watch_expense_categories.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mocktail/mocktail.dart';

class MockExpenseCategoryRepository extends Mock
    implements IExpenseCategoryRepository {}

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  const userId = 'userId';
  const traceId = 'traceId';
  const expectedParentCode = '50.0000';
  final parent = Account(
    code: expectedParentCode,
    name: 'expense',
    type: AccountType.expense,
    isSystemAccount: true,
  );
  final accounts = List.generate(
    5,
    (idx) => Account(
      code: '50.000${idx + 1}',
      name: 'expense $idx',
      type: parent.type,
      parent: parent,
    ),
  );
  final categories = accounts
      .map(
        (it) => ExpenseCategory(
          id: it.code,
          name: it.name,
          icon: '',
          account: it,
        ),
      )
      .toList();

  late IAuthRepository mockAuthRepository;
  late IExpenseCategoryRepository mockExpenseCategoryRepository;
  late WatchExpenseCategoriesUseCase useCase;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    when(
      () => mockAuthRepository.getCurrentUserId(traceId: traceId),
    ).thenAnswer((_) async => const AppResult.success(userId));

    mockExpenseCategoryRepository = MockExpenseCategoryRepository();
    when(
      () => mockExpenseCategoryRepository.watch(
        userId: userId,
        traceId: traceId,
        query: any(named: 'query'),
        isDeleted: any(named: 'isDeleted'),
      ),
    ).thenAnswer((_) => Stream.value(AppResult.success(categories)));

    useCase = WatchExpenseCategoriesUseCase(
      authRepository: mockAuthRepository,
      expenseCategoryRepository: mockExpenseCategoryRepository,
    );
  });

  test(
    'calls AuthRepository.getCurrentUserId once '
    'to get current user id',
    () async {
      final result = useCase.execute(
        const WatchExpenseCategoriesParams(),
        traceId: traceId,
      );
      await result.first;

      verify(
        () => mockAuthRepository.getCurrentUserId(traceId: traceId),
      ).called(1);
    },
  );

  test(
    'calls ExpenseCategoryRepository.watch once '
    'with correct args',
    () async {
      final result = useCase.execute(
        const WatchExpenseCategoriesParams(),
        traceId: traceId,
      );
      await result.first;

      verify(
        () => mockExpenseCategoryRepository.watch(
          userId: userId,
          traceId: traceId,
          isDeleted: false,
        ),
      ).called(1);
    },
  );

  test(
    'calls ExpenseCategoryRepository.watch once '
    'with correct args when query provided',
    () async {
      final result = useCase.execute(
        const WatchExpenseCategoriesParams(query: 'query'),
        traceId: traceId,
      );
      await result.first;

      verify(
        () => mockExpenseCategoryRepository.watch(
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
        const WatchExpenseCategoriesParams(),
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
        const WatchExpenseCategoriesParams(),
        traceId: traceId,
      );

      expect(
        result,
        emits(
          AppResult<List<ExpenseCategory>>.failure(
            AppException.test(),
          ),
        ),
      );
      verifyZeroInteractions(mockExpenseCategoryRepository);
    },
  );

  test(
    'emits failure '
    'when ExpenseCategoryRepository.watch emits failure',
    () async {
      when(
        () => mockExpenseCategoryRepository.watch(
          userId: userId,
          traceId: traceId,
          isDeleted: false,
        ),
      ).thenAnswer((_) => Stream.value(AppResult.failure(AppException.test())));

      final result = useCase.execute(
        const WatchExpenseCategoriesParams(),
        traceId: traceId,
      );

      expect(
        result,
        emits(
          AppResult<List<ExpenseCategory>>.failure(AppException.test()),
        ),
      );
    },
  );
}
