import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/repositories/i_account_repository.dart';
import 'package:journexa_app/domain/use_cases/account/initialize_accounts.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mocktail/mocktail.dart';

class MockAccountRepository extends Mock implements IAccountRepository;

void main() {
  const traceId = 'trace';

  final IAccountRepository mockAccountRepository = MockAccountRepository();
  final useCase = InitializeAccountsUseCase(
    accountRepository: mockAccountRepository,
  );

  setUpAll(() {
    registerFallbackValue(Account.test());
  });

  setUp(() {
    when(
      () => mockAccountRepository.ensureSaved(
        accounts: SystemDefinedAccount.accounts,
        traceId: traceId,
      ),
    ).thenAnswer((_) async => const AppResult.success(null));
  });

  tearDown(() {
    reset(mockAccountRepository);
  });

  test(
    'calls ensureSaved once with current user id '
    'and default system accounts',
    () async {
      await useCase.execute(traceId: traceId);

      verify(
        () => mockAccountRepository.ensureSaved(
          accounts: SystemDefinedAccount.accounts,
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
          accounts: SystemDefinedAccount.accounts,
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
          accounts: SystemDefinedAccount.accounts,
          traceId: traceId,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockAccountRepository);
    },
  );
}
