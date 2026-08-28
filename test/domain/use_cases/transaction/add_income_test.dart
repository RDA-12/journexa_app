import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/income_category.dart'
    show IncomeCategory;
import 'package:journexa_app/domain/entities/journal.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/repositories/i_transaction_repository.dart';
import 'package:journexa_app/domain/use_cases/transaction/add_income.dart';
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
  final wallet = Wallet.test();
  final category = IncomeCategory.test();
  final transaction = Transaction.income(
    id: 'id',
    wallet: wallet,
    category: category,
    amount: amount,
    date: date,
  );
  final params = AddIncomeParams(
    wallet: wallet,
    category: category,
    amount: amount,
    date: date,
  );

  late IAuthRepository mockAuthRepository;
  late ITransactionRepository mockTransactionRepository;
  late UidGenerator mockUidGenerator;
  late AddIncomeUseCase useCase;

  setUpAll(() {
    registerFallbackValue(
      Transaction.test(amount: amount, date: DateTime.now()),
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

    useCase = AddIncomeUseCase(
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
                account: transaction.wallet.account,
                debit: amount,
                credit: Decimal.zero,
              ),
              JournalEntryLine(
                account: transaction.category.account,
                debit: Decimal.zero,
                credit: amount,
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

      expect(result, AppResult.success(transaction));
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
