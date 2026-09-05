import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/repositories/i_journal_repository.dart';
import 'package:journexa_app/domain/use_cases/journal/watch_current_balance.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mocktail/mocktail.dart';

class MockJournalRepository extends Mock implements IJournalRepository {}

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  const userId = 'userId';
  const traceId = 'traceId';
  final balances = {
    '40.0001': Decimal.zero,
    '40.0002': Decimal.fromInt(100000),
    '10.0001': Decimal.fromInt(1000),
  };

  late IAuthRepository mockAuthRepository;
  late IJournalRepository mockJournalRepository;
  late WatchCurrentBalanceUseCase useCase;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    when(
      () => mockAuthRepository.getCurrentUserId(traceId: traceId),
    ).thenAnswer((_) async => const AppResult.success(userId));

    mockJournalRepository = MockJournalRepository();
    when(
      () => mockJournalRepository.watchCurrentBalance(
        userId: userId,
        traceId: traceId,
      ),
    ).thenAnswer((_) => Stream.value(AppResult.success(balances)));

    useCase = WatchCurrentBalanceUseCase(
      authRepository: mockAuthRepository,
      journalRepository: mockJournalRepository,
    );
  });

  test(
    'calls AuthRepository.getCurrentUserId once '
    'to get current user id',
    () async {
      final result = useCase.execute(
        traceId: traceId,
      );
      await result.first;

      verify(
        () => mockAuthRepository.getCurrentUserId(traceId: traceId),
      ).called(1);
    },
  );

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
          userId: userId,
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
    'emits failure and not fetch Accounts '
    'when AuthRepository.getCurrentUserId failed',
    () async {
      when(
        () => mockAuthRepository.getCurrentUserId(traceId: traceId),
      ).thenAnswer((_) async => AppResult<String>.failure(AppException.test()));

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
      verifyZeroInteractions(mockJournalRepository);
    },
  );

  test(
    'emits failure '
    'when JournalRepository.watch emits failure',
    () async {
      when(
        () => mockJournalRepository.watchCurrentBalance(
          userId: userId,
          traceId: traceId,
        ),
      ).thenAnswer((_) => Stream.value(AppResult.failure(AppException.test())));

      final result = useCase.execute(
        traceId: traceId,
      );

      expect(
        result,
        emits(
          AppResult<Map<String, Decimal>>.failure(AppException.test()),
        ),
      );
    },
  );
}
