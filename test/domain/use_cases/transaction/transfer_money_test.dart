import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/journal.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/repositories/i_transaction_repository.dart';
import 'package:journexa_app/domain/use_cases/transaction/transfer_money.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

class MockTransactionRepository extends Mock
    implements ITransactionRepository {}

class MockUidGenerator extends Mock implements UidGenerator {}

void main() {
  const traceId = 'traceId';
  const userId = 'userId';
  const id = 'id';
  final date = DateTime.now();
  final amount = Decimal.fromInt(100000);
  final fee = Decimal.fromInt(2500);
  final source = Wallet.test();
  final destination =
      Wallet.test().update(name: 'wallet 2').copyWith(id: 'id-2');
  final transaction = TransferTransaction(
    id: 'id',
    source: source,
    destination: destination,
    amount: amount,
    fee: fee,
    date: date,
  );
  final params = TransferMoneyParams(
    source: source,
    destination: destination,
    amount: amount,
    fee: fee,
    date: date,
  );

  late IAuthRepository mockAuthRepository;
  late ITransactionRepository mockTransactionRepository;
  late UidGenerator mockUidGenerator;
  late TransferMoneyUseCase useCase;

  setUpAll(() {
    registerFallbackValue(
      Transaction.testTransfer(amount: amount, date: DateTime.now(), fee: fee),
    );
    registerFallbackValue(
      JournalEntry.test(lines: [], transactionDate: DateTime.now()),
    );
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    when(
      () => mockAuthRepository.getCurrentUserId(traceId: traceId),
    ).thenAnswer((_) async => const AppResult.success(userId));

    mockTransactionRepository = MockTransactionRepository();
    when(
      () => mockTransactionRepository.save(
        userId: userId,
        transaction: any<Transaction>(named: 'transaction'),
        journalEntry: any<JournalEntry>(named: 'journalEntry'),
        traceId: traceId,
      ),
    ).thenAnswer((_) async => const AppResult.success(null));

    mockUidGenerator = MockUidGenerator();
    when(mockUidGenerator.generateUid).thenReturn(id);

    useCase = TransferMoneyUseCase(
      authRepository: mockAuthRepository,
      transactionRepository: mockTransactionRepository,
    )..customGenerator = mockUidGenerator;
  });

  test(
    'calls AuthRepository.getCurrentUserId once '
    'to get current user id',
    () async {
      await useCase.execute(
        params,
        traceId: traceId,
      );

      verify(
        () => mockAuthRepository.getCurrentUserId(traceId: traceId),
      ).called(1);
    },
  );

  test(
    'calls TransactionRepository.save once '
    'with correct transaction and journal entry',
    () async {
      await useCase.execute(
        params,
        traceId: traceId,
      );

      verify(
        () => mockTransactionRepository.save(
          userId: userId,
          transaction: transaction,
          journalEntry: JournalEntry.test(
            lines: [
              JournalEntryLine(
                account: transaction.source.account,
                debit: Decimal.zero,
                credit: amount + fee,
              ),
              JournalEntryLine(
                account: transaction.destination.account,
                debit: amount,
                credit: Decimal.zero,
              ),
              JournalEntryLine(
                account: SystemDefinedAccount.feeTransfer,
                debit: fee,
                credit: Decimal.zero,
              ),
            ],
            transactionDate: date,
            description: transaction.notes,
          ),
          traceId: traceId,
        ),
      ).called(1);
    },
  );

  test(
    'returns success with Transaction when all operations succeeded',
    () async {
      final result = await useCase.execute(
        params,
        traceId: traceId,
      );

      expect(result, AppResult<Transaction>.success(transaction));
    },
  );

  test(
    'returns failure and not save Transaction '
    'when AuthRepository.getCurrentUserId fails',
    () async {
      when(
        () => mockAuthRepository.getCurrentUserId(traceId: traceId),
      ).thenAnswer((_) async => AppResult.failure(AppException.test()));

      final result = await useCase.execute(
        params,
        traceId: traceId,
      );

      expect(result, AppResult<Transaction>.failure(AppException.test()));
      verifyZeroInteractions(mockTransactionRepository);
    },
  );

  test(
    'returns failure when TransactionRepository.save fails',
    () async {
      when(
        () => mockTransactionRepository.save(
          userId: userId,
          transaction: any<Transaction>(named: 'transaction'),
          journalEntry: any<JournalEntry>(named: 'journalEntry'),
          traceId: traceId,
        ),
      ).thenAnswer((_) async => AppResult<Null>.failure(AppException.test()));

      final result = await useCase.execute(
        params,
        traceId: traceId,
      );

      expect(result, AppResult<Transaction>.failure(AppException.test()));
    },
  );
}
