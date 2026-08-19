import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/repositories/i_account_repository.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/use_cases/account/update_account.dart';
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
    name: 'asset 1',
    type: AccountType.asset,
  );
  final params = UpdateAccountParams(
    code: account.code,
    name: 'new name',
  );
  final updatedAccount = account.copyWith(
    name: params.name!,
  );

  late IAuthRepository mockAuthRepository;
  late IAccountRepository mockAccountRepository;
  late UpdateAccountUseCase useCase;

  setUpAll(() {
    registerFallbackValue(updatedAccount);
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    when(
      () => mockAuthRepository.getCurrentUserId(traceId: traceId),
    ).thenAnswer((_) async => const AppResult.success(userId));

    mockAccountRepository = MockAccountRepository();
    when(
      () => mockAccountRepository.getByCode(
        userId: userId,
        code: account.code,
        traceId: traceId,
      ),
    ).thenAnswer((_) async => AppResult.success(account));
    when(
      () =>
          mockAccountRepository.save(userId, updatedAccount, traceId: traceId),
    ).thenAnswer((_) async => const AppResult.success(null));

    useCase = UpdateAccountUseCase(
      authRepository: mockAuthRepository,
      accountRepository: mockAccountRepository,
    );
  });

  test('calls AuthRepository.getCurrentUserId '
      'once to get current user id', () async {
    await useCase.execute(params, traceId: traceId);

    verify(
      () => mockAuthRepository.getCurrentUserId(traceId: traceId),
    ).called(1);
  });

  test('calls AccountRepository.getByCode once '
      'to get requested account', () async {
    await useCase.execute(params, traceId: traceId);

    verify(
      () => mockAccountRepository.getByCode(
        userId: userId,
        code: account.code,
        traceId: traceId,
      ),
    ).called(1);
  });

  test('calls AccountRepository.save once '
      'to save updated Account', () async {
    await useCase.execute(params, traceId: traceId);

    verify(
      () =>
          mockAccountRepository.save(userId, updatedAccount, traceId: traceId),
    ).called(1);
  });

  test(
    'returns success with updated Account '
    'when all operations succeeded',
    () async {
      final result = await useCase.execute(params, traceId: traceId);

      expect(result, AppResult.success(updatedAccount));
    },
  );

  test('returns failure and not get/saving Account '
      'when AuthRepository.getCurrentUserId failed', () async {
    when(
      () => mockAuthRepository.getCurrentUserId(
        traceId: traceId,
      ),
    ).thenAnswer((_) async => AppResult<String>.failure(AppException.test()));

    final result = await useCase.execute(params, traceId: traceId);

    expect(result, AppResult<Account>.failure(AppException.test()));
    verifyZeroInteractions(mockAccountRepository);
  });

  test('returns failure and not saving Account '
      'when AccountRepository.getByCode failed', () async {
    when(
      () => mockAccountRepository.getByCode(
        userId: userId,
        code: account.code,
        traceId: traceId,
      ),
    ).thenAnswer((_) async => AppResult<Account>.failure(AppException.test()));

    final result = await useCase.execute(params, traceId: traceId);

    expect(result, AppResult<Account>.failure(AppException.test()));
    verifyNever(
      () => mockAccountRepository.save(
        userId,
        updatedAccount,
        traceId: traceId,
      ),
    );
  });

  test('returns failure '
      'when AccountRepository.save failed', () async {
    when(
      () => mockAccountRepository.save(
        userId,
        updatedAccount,
        traceId: traceId,
      ),
    ).thenAnswer((_) async => AppResult<Null>.failure(AppException.test()));

    final result = await useCase.execute(params, traceId: traceId);

    expect(result, AppResult<Account>.failure(AppException.test()));
  });
}
