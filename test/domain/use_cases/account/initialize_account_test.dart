import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/repositories/i_account_repository.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/use_cases/account/initialize_accounts.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mocktail/mocktail.dart';

class MockAccountRepository extends Mock implements IAccountRepository {}

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  const traceId = 'trace';
  const userId = 'userIdTest';

  final IAuthRepository mockAuthRepository = MockAuthRepository();
  final IAccountRepository mockAccountRepository = MockAccountRepository();
  final useCase = InitializeAccountsUseCase(
    accountRepository: mockAccountRepository,
    authRepository: mockAuthRepository,
  );

  setUpAll(() {
    registerFallbackValue(Account.test());
  });

  setUp(() {
    when(
      () => mockAccountRepository.ensureSaved(
        userId,
        accounts: kSystemDefinedAccounts,
        traceId: traceId,
      ),
    ).thenAnswer((_) async => const AppResult.success(null));
    when(
      () => mockAuthRepository.getCurrentUserId(traceId: traceId),
    ).thenAnswer((_) async => const AppResult.success(userId));
  });

  tearDown(() {
    reset(mockAccountRepository);
    reset(mockAuthRepository);
  });

  test(
    'calls ensureSaved once with current user id '
    'and default system accounts',
    () async {
      await useCase.execute(traceId: traceId);

      verify(
        () => mockAccountRepository.ensureSaved(
          userId,
          accounts: kSystemDefinedAccounts,
          traceId: traceId,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockAccountRepository);
    },
  );

  test(
    'returns failure result when ensureSaved is fails',
    () async {
      when(
        () => mockAccountRepository.ensureSaved(
          userId,
          accounts: kSystemDefinedAccounts,
          traceId: traceId,
        ),
      ).thenAnswer(
        (_) async => AppResult<void>.failure(
          AppException.test(),
        ),
      );

      final result = await useCase.execute(traceId: traceId);

      expect(result, AppResult<void>.failure(AppException.test()));
      verify(
        () => mockAccountRepository.ensureSaved(
          userId,
          accounts: kSystemDefinedAccounts,
          traceId: traceId,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockAccountRepository);
    },
  );
}
