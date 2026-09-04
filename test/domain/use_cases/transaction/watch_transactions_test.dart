import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/repositories/i_transaction_repository.dart';
import 'package:journexa_app/domain/use_cases/transaction/watch_transactions.dart';
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
      amount: Decimal.fromInt(10 * (index + 1)),
      date: DateTime.now(),
      fee: Decimal.zero,
    ),
  ).toList();

  late IAuthRepository mockAuthRepository;
  late ITransactionRepository mockTransactionRepository;
  late WatchTransactionsUseCase useCase;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    when(
      () => mockAuthRepository.getCurrentUserId(traceId: traceId),
    ).thenAnswer((_) async => const AppResult.success(userId));

    mockTransactionRepository = MockTransactionRepository();
    when(
      () => mockTransactionRepository.watch(userId: userId, traceId: traceId),
    ).thenAnswer((_) => Stream.value(AppResult.success(transactions)));

    useCase = WatchTransactionsUseCase(
      authRepository: mockAuthRepository,
      transactionRepository: mockTransactionRepository,
    );
  });

  test(
    'calls AuthRepository.getCurrentUserId once '
    'to get current user id',
    () async {
      final result = useCase.execute(traceId: traceId);
      await result.first;

      verify(
        () => mockAuthRepository.getCurrentUserId(traceId: traceId),
      ).called(1);
    },
  );

  test(
    'calls TransactionRepository.watch once '
    'with correct args',
    () async {
      final result = useCase.execute(traceId: traceId);
      await result.first;

      verify(
        () => mockTransactionRepository.watch(
          userId: userId,
          traceId: traceId,
        ),
      ).called(1);
    },
  );

  test(
    'emits correct transactions when all operations are successful',
    () async {
      final result = useCase.execute(traceId: traceId);

      expect(result, emits(AppResult.success(transactions)));
    },
  );

  test(
    'emits failure and does not call TransactionRepository '
    'when AuthRepository.getCurrentUserId failed',
    () async {
      when(
        () => mockAuthRepository.getCurrentUserId(traceId: traceId),
      ).thenAnswer((_) async => AppResult<String>.failure(AppException.test()));

      final result = useCase.execute(traceId: traceId);

      expect(
        result,
        emits(
          AppResult<List<Transaction>>.failure(
            AppException.test(),
          ),
        ),
      );
      verifyZeroInteractions(mockTransactionRepository);
    },
  );

  test(
    'emits failure '
    'when TransactionRepository.watch emits failure',
    () async {
      when(
        () => mockTransactionRepository.watch(
          userId: userId,
          traceId: traceId,
        ),
      ).thenAnswer((_) => Stream.value(AppResult.failure(AppException.test())));

      final result = useCase.execute(traceId: traceId);

      expect(
        result,
        emits(
          AppResult<List<Transaction>>.failure(AppException.test()),
        ),
      );
    },
  );
}
