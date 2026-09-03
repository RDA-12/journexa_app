import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/repositories/i_transaction_repository.dart';
import 'package:journexa_app/domain/use_cases/transaction/get_all_transactions.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

class MockTransactionRepository extends Mock
    implements ITransactionRepository {}

void main() {
  const traceId = 'traceId';
  const userId = 'userId';
  final transactions = List.generate(
    5,
    (index) => Transaction.testTransfer(
      amount: Decimal.fromInt(10 * index),
      date: DateTime.now(),
      fee: Decimal.zero,
    ),
  ).toList();

  late IAuthRepository mockAuthRepository;
  late ITransactionRepository mockTransactionRepository;
  late GetAllTransactionsUseCase useCase;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    when(
      () => mockAuthRepository.getCurrentUserId(traceId: traceId),
    ).thenAnswer((_) async => const AppResult.success(userId));

    mockTransactionRepository = MockTransactionRepository();
    when(
      () => mockTransactionRepository.getAll(userId: userId, traceId: traceId),
    ).thenAnswer((_) async => AppResult.success(transactions));

    useCase = GetAllTransactionsUseCase(
      authRepository: mockAuthRepository,
      transactionRepository: mockTransactionRepository,
    );
  });

  testWidgets(
    'calls AuthRepository.getCurrentUserId once '
    'to get current user id',
    (tester) async {
      await useCase.execute(traceId: traceId);

      verify(
        () => mockAuthRepository.getCurrentUserId(traceId: traceId),
      ).called(1);
    },
  );

  testWidgets(
    'calls TransactionRepository.getAll once '
    'to get all transactions for current user',
    (tester) async {
      await useCase.execute(traceId: traceId);

      verify(
        () =>
            mockTransactionRepository.getAll(userId: userId, traceId: traceId),
      ).called(1);
    },
  );

  testWidgets(
    'returns success with transactions '
    'when all operations are succeeded',
    (tester) async {
      final result = await useCase.execute(traceId: traceId);

      expect(result, AppResult.success(transactions));
    },
  );

  testWidgets(
    'returns failure and not get transactions '
    'when AuthRepository.getCurrentUserId fails',
    (tester) async {
      when(
        () => mockAuthRepository.getCurrentUserId(traceId: traceId),
      ).thenAnswer((_) async => AppResult.failure(AppException.test()));

      final result = await useCase.execute(traceId: traceId);

      expect(result, AppResult<List<Transaction>>.failure(AppException.test()));
      verifyZeroInteractions(mockTransactionRepository);
    },
  );

  testWidgets(
    'returns failure '
    'when TransactionRepository.getAll fails',
    (tester) async {
      when(
        () =>
            mockTransactionRepository.getAll(userId: userId, traceId: traceId),
      ).thenAnswer((_) async => AppResult.failure(AppException.test()));

      final result = await useCase.execute(traceId: traceId);

      expect(result, AppResult<List<Transaction>>.failure(AppException.test()));
      verify(
        () => mockAuthRepository.getCurrentUserId(traceId: traceId),
      ).called(1);
    },
  );
}
