import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/repositories/i_account_repository.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/use_cases/account/delete_account.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

class MockAccountRepository extends Mock implements IAccountRepository {}

void main() {
  const userId = 'userId';
  const traceId = 'traceId';
  final account = Account(
    code: '10.0001',
    name: 'asset',
    type: AccountType.asset,
  );
  final params = DeleteAccountParams(account: account);

  late IAuthRepository mockAuthRepository;
  late IAccountRepository mockAccountRepository;
  late DeleteAccountUseCase useCase;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    when(
      () => mockAuthRepository.getCurrentUserId(traceId: traceId),
    ).thenAnswer((_) async => const AppResult.success(userId));

    mockAccountRepository = MockAccountRepository();
    when(
      () => mockAccountRepository.deleteByCode(
        userId: userId,
        code: params.account.code,
        traceId: traceId,
      ),
    ).thenAnswer((_) async => const AppResult.success(null));

    useCase = DeleteAccountUseCase(
      authRepository: mockAuthRepository,
      accountRepository: mockAccountRepository,
    );
  });

  test(
    'calls AuthRepository.getCurrentUserId once '
    'to get current user id',
    () async {
      await useCase.execute(params, traceId: traceId);

      verify(
        () => mockAuthRepository.getCurrentUserId(traceId: traceId),
      ).called(1);
    },
  );

  test(
    'calls AccountRepository.deleteByCode once '
    'with correct args',
    () async {
      await useCase.execute(params, traceId: traceId);

      verify(
        () => mockAccountRepository.deleteByCode(
          userId: userId,
          code: params.account.code,
          traceId: traceId,
        ),
      );
    },
  );

  test('returns success when all operations are succeeded', () async {
    final result = await useCase.execute(params, traceId: traceId);

    expect(result, const AppResult.success(null));
  });

  test(
    'returns failure when AuthRepository.getCurrentUserId failed '
    'and not call AccountRepository.deleteByCode',
    () async {
      when(
        () => mockAuthRepository.getCurrentUserId(traceId: traceId),
      ).thenAnswer((_) async => AppResult.failure(AppException.test()));

      final result = await useCase.execute(params, traceId: traceId);

      expect(result, AppResult<Null>.failure(AppException.test()));
      verifyZeroInteractions(mockAccountRepository);
    },
  );

  test(
    'returns failure when AccountRepository.deleteByCode failed',
    () async {
      when(
        () => mockAccountRepository.deleteByCode(
          userId: userId,
          code: params.account.code,
          traceId: traceId,
        ),
      ).thenAnswer((_) async => AppResult.failure(AppException.test()));

      final result = await useCase.execute(params, traceId: traceId);

      expect(result, AppResult<Null>.failure(AppException.test()));
    },
  );
}
