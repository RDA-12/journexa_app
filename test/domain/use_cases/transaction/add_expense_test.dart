import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/expense_category.dart';
import 'package:journexa_app/domain/entities/journal.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/repositories/i_journal_repository.dart';
import 'package:journexa_app/domain/repositories/i_transaction_repository.dart';
import 'package:journexa_app/domain/use_cases/transaction/add_expense.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';
import 'package:mocktail/mocktail.dart';

class MockJournalRepository extends Mock implements IJournalRepository;

class MockTransactionRepository extends Mock implements ITransactionRepository;

class MockUidGenerator extends Mock implements UidGenerator;

void main() {
  const traceId = 'traceId';
  const id = 'id';
  final date = DateTime.now();
  final amount = Decimal.fromInt(100000);
  final wallet = Wallet.test();
  final category = ExpenseCategory.test();
  final transaction = ExpenseTransaction(
    id: 'id',
    walletId: wallet.id,
    expenseCategoryId: category.id,
    amount: amount,
    date: date,
  );
  final params = AddExpenseParams(
    wallet: wallet,
    category: category,
    amount: amount,
    date: date,
  );

  late ITransactionRepository mockTransactionRepository;
  late IJournalRepository mockJournalRepository;
  late UidGenerator mockUidGenerator;
  late AddExpenseUseCase useCase;

  setUpAll(() {
    registerFallbackValue(
      Transaction.testExpense(amount: amount, date: DateTime.now()),
    );
    registerFallbackValue(
      JournalEntry.test(lines: [], transactionDate: DateTime.now()),
    );
    registerFallbackValue(Account.test());
  });

  setUp(() {
    mockJournalRepository = MockJournalRepository();
    when(
      () => mockJournalRepository.getAccountBalance(
        account: any(named: 'account'),
        traceId: traceId,
      ),
    ).thenAnswer(
      (_) async => AppResult.success(amount + Decimal.fromInt(100000)),
    );

    mockTransactionRepository = MockTransactionRepository();
    when(
      () => mockTransactionRepository.save(
        transaction: any<Transaction>(named: 'transaction'),
        journalEntry: any<JournalEntry>(named: 'journalEntry'),
        traceId: traceId,
      ),
    ).thenAnswer((_) async => const AppResult.success(null));

    mockUidGenerator = MockUidGenerator();
    when(mockUidGenerator.generateUid).thenReturn(id);

    useCase = AddExpenseUseCase(
      journalRepository: mockJournalRepository,
      transactionRepository: mockTransactionRepository,
    )..customGenerator = mockUidGenerator;
  });

  test(
    'calls JournalRepository.getAccountBalance once '
    'with correct params',
    () async {
      await useCase.execute(
        params,
        traceId: traceId,
      );

      verify(
        () => mockJournalRepository.getAccountBalance(
          account: wallet.account,
          traceId: traceId,
        ),
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
          transaction: transaction,
          journalEntry: JournalEntry.test(
            lines: [
              JournalEntryLine(
                account: wallet.account,
                debit: Decimal.zero,
                credit: amount,
              ),
              JournalEntryLine(
                account: category.account,
                debit: amount,
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
    'when wallet balance is not enough',
    () async {
      when(
        () => mockJournalRepository.getAccountBalance(
          account: any(named: 'account'),
          traceId: traceId,
        ),
      ).thenAnswer(
        (_) async => AppResult.success(amount - Decimal.fromInt(1)),
      );

      final result = await useCase.execute(params, traceId: traceId);

      expect(
        result,
        isA<AppResultFailure<Transaction>>().having(
          (e) => e.error.code,
          'error.code',
          equals(AppExceptionCode.insufficientWalletBalance),
        ),
      );
      verifyZeroInteractions(mockTransactionRepository);
    },
  );

  test(
    'returns failure when TransactionRepository.save fails',
    () async {
      when(
        () => mockTransactionRepository.save(
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
