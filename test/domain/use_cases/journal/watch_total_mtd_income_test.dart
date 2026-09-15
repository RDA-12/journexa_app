import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/repositories/i_journal_repository.dart';
import 'package:journexa_app/domain/use_cases/journal/watch_total_mtd_income.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mocktail/mocktail.dart';

class MockJournalRepository extends Mock implements IJournalRepository;

void main() {
  const traceId = 'traceId';
  final targetDate = DateTime(2026, 10, 12, 22, 30);
  final params = WatchTotalMTDIncomeParams(targetDate: targetDate);
  final expectedFromDate = DateTime(2026, 10);
  final expectedToDate = DateTime(2026, 10, 12, 23, 59, 59, 999);
  final expectedAccount = SystemDefinedAccount.incomeParent;
  final totalBalance = Decimal.fromInt(100000);

  late IJournalRepository mockJournalRepository;
  late WatchTotalMTDIncomeUseCase useCase;

  setUpAll(() {
    registerFallbackValue(expectedAccount);
  });

  setUp(() {
    mockJournalRepository = MockJournalRepository();
    when(
      () => mockJournalRepository.watchAccountBalance(
        account: any<Account>(named: 'account'),
        counterpartAccount: any<Account>(named: 'counterpartAccount'),
        from: any<DateTime>(named: 'from'),
        to: any<DateTime>(named: 'to'),
        traceId: traceId,
      ),
    ).thenAnswer((_) => Stream.value(AppResult.success(totalBalance)));

    useCase = WatchTotalMTDIncomeUseCase(
      journalRepository: mockJournalRepository,
    );
  });

  test(
    'calls JournalRepository.watchAccountBalance once '
    'with correct arguments',
    () async {
      useCase.execute(
        params,
        traceId: traceId,
      );

      verify(
        () => mockJournalRepository.watchAccountBalance(
          account: expectedAccount,
          from: expectedFromDate,
          to: expectedToDate,
          traceId: traceId,
        ),
      ).called(1);

      final wallet = Wallet.test();
      useCase.execute(params.copyWith(wallet: wallet), traceId: traceId);
      verify(
        () => mockJournalRepository.watchAccountBalance(
          account: expectedAccount,
          counterpartAccount: wallet.account,
          from: expectedFromDate,
          to: expectedToDate,
          traceId: traceId,
        ),
      ).called(1);
    },
  );

  test(
    'emits correct balance when succeeded',
    () {
      final result = useCase.execute(
        params,
        traceId: traceId,
      );

      expect(result, emits(AppResult.success(totalBalance)));
    },
  );

  test(
    'emits failure '
    'when JournalRepository.watchAccountBalance emits failure',
    () {
      when(
        () => mockJournalRepository.watchAccountBalance(
          account: expectedAccount,
          from: any(named: 'from'),
          to: any(named: 'to'),
          traceId: traceId,
        ),
      ).thenAnswer((_) => Stream.value(AppResult.failure(AppException.test())));

      final result = useCase.execute(
        params,
        traceId: traceId,
      );

      expect(
        result,
        emits(AppResult<Decimal>.failure(AppException.test())),
      );
    },
  );
}
