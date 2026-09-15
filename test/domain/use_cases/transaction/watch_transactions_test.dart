import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/repositories/i_transaction_repository.dart';
import 'package:journexa_app/domain/use_cases/transaction/watch_transactions.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionRepository extends Mock
    implements ITransactionRepository {}

void main() {
  const traceId = 'traceId';
  const params = WatchTransactionsParams();
  final transactions = List.generate(
    5,
    (index) => Transaction.testTransfer(
      amount: Decimal.fromInt(10 * (index + 1)),
      date: DateTime.now(),
      fee: Decimal.zero,
    ),
  ).toList();

  late ITransactionRepository mockTransactionRepository;
  late WatchTransactionsUseCase useCase;

  setUp(() {
    mockTransactionRepository = MockTransactionRepository();
    when(
      () => mockTransactionRepository.watch(
        traceId: traceId,
        wallet: any(named: 'wallet'),
      ),
    ).thenAnswer((_) => Stream.value(AppResult.success(transactions)));

    useCase = WatchTransactionsUseCase(
      transactionRepository: mockTransactionRepository,
    );
  });

  test(
    'calls TransactionRepository.watch once '
    'with correct args',
    () async {
      final result = useCase.execute(params, traceId: traceId);
      await result.first;

      verify(
        () => mockTransactionRepository.watch(
          traceId: traceId,
        ),
      ).called(1);

      final wallet = Wallet.test();
      final filteredResult = useCase.execute(
        params.copyWith(wallet: wallet),
        traceId: traceId,
      );
      await filteredResult.first;

      verify(
        () => mockTransactionRepository.watch(
          traceId: traceId,
          wallet: wallet,
        ),
      ).called(1);
    },
  );

  test(
    'emits correct transactions when all operations are successful',
    () async {
      final result = useCase.execute(params, traceId: traceId);

      expect(result, emits(AppResult.success(transactions)));
    },
  );

  test(
    'emits failure '
    'when TransactionRepository.watch emits failure',
    () async {
      when(
        () => mockTransactionRepository.watch(
          traceId: traceId,
          wallet: any(named: 'wallet'),
        ),
      ).thenAnswer((_) => Stream.value(AppResult.failure(AppException.test())));

      final result = useCase.execute(params, traceId: traceId);

      expect(
        result,
        emits(
          AppResult<List<Transaction>>.failure(AppException.test()),
        ),
      );
    },
  );
}
