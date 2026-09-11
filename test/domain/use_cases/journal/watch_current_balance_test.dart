import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/repositories/i_journal_repository.dart';
import 'package:journexa_app/domain/use_cases/journal/watch_current_balance.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mocktail/mocktail.dart';

class MockJournalRepository extends Mock implements IJournalRepository {}

void main() {
  const traceId = 'traceId';
  final balances = {
    '40.0001': Decimal.zero,
    '40.0002': Decimal.fromInt(100000),
    '10.0001': Decimal.fromInt(1000),
  };

  late IJournalRepository mockJournalRepository;
  late WatchCurrentBalanceUseCase useCase;

  setUp(() {
    mockJournalRepository = MockJournalRepository();
    when(
      () => mockJournalRepository.watchCurrentBalance(
        traceId: traceId,
      ),
    ).thenAnswer((_) => Stream.value(AppResult.success(balances)));

    useCase = WatchCurrentBalanceUseCase(
      journalRepository: mockJournalRepository,
    );
  });

  test(
    'calls JournalRepository.watchCurrentBalance once '
    'with correct args',
    () async {
      final result = useCase.execute(
        traceId: traceId,
      );
      await result.first;

      verify(
        () => mockJournalRepository.watchCurrentBalance(
          traceId: traceId,
        ),
      ).called(1);
    },
  );

  test(
    'emits correct balances when all operations are successful',
    () async {
      final result = useCase.execute(
        traceId: traceId,
      );

      expect(result, emits(AppResult.success(balances)));
    },
  );

  test(
    'emits failure '
    'when JournalRepository.watchCurrentBalance emits failure',
    () async {
      when(
        () => mockJournalRepository.watchCurrentBalance(
          traceId: traceId,
        ),
      ).thenAnswer(
        (_) => Stream.value(
          AppResult<Map<String, Decimal>>.failure(
            AppException.test(),
          ),
        ),
      );

      final result = useCase.execute(
        traceId: traceId,
      );

      expect(
        result,
        emits(
          AppResult<Map<String, Decimal>>.failure(
            AppException.test(),
          ),
        ),
      );
    },
  );
}
