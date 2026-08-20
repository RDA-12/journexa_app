import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/repositories/i_account_repository.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/use_cases/account/add_wallet.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

class MockAccountRepository extends Mock implements IAccountRepository {}

void main() {
  const traceId = 'trace';
  const userId = 'userId';
  const currentChildrenCount = 10;
  const nextCode = '10.0011';
  const params = AddWalletParams(
    name: 'my wallet',
  );

  late IAuthRepository mockAuthRepository;
  late IAccountRepository mockAccountRepository;
  late AddWalletUseCase useCase;

  setUpAll(() {
    registerFallbackValue(Account.test());
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    when(
      () => mockAuthRepository.getCurrentUserId(traceId: traceId),
    ).thenAnswer(
      (_) async => const AppResult.success(userId),
    );

    mockAccountRepository = MockAccountRepository();
    when(
      () => mockAccountRepository.getChildrenCountByParentCode(
        userId: any<String>(named: 'userId'),
        parentCode: any<String>(named: 'parentCode'),
        traceId: traceId,
      ),
    ).thenAnswer(
      (_) async => const AppResult.success(currentChildrenCount),
    );
    when(
      () => mockAccountRepository.save(
        any<String>(),
        any<Account>(),
        traceId: traceId,
      ),
    ).thenAnswer(
      (_) async => const AppResult.success(null),
    );

    useCase = AddWalletUseCase(
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
    'calls AccountRepository.getChildrenCountByParentCode once '
    'to get current asset account children count',
    () async {
      await useCase.execute(params, traceId: traceId);

      verify(
        () => mockAccountRepository.getChildrenCountByParentCode(
          userId: userId,
          parentCode: '10.0000',
          traceId: traceId,
        ),
      ).called(1);
    },
  );

  test(
    'calls AccountRepository.save once '
    'with correct userId and Account',
    () async {
      final expectedAccount = Account(
        code: nextCode,
        name: params.name,
        type: AccountType.asset,
        parent: Account(
          code: '10.0000',
          name: 'asset',
          type: AccountType.asset,
          isSystemAccount: true,
        ),
      );

      await useCase.execute(params, traceId: traceId);

      verify(
        () => mockAccountRepository.save(
          userId,
          expectedAccount,
          traceId: traceId,
        ),
      ).called(1);
    },
  );

  test(
    'returns AppResult.success when all operations are successful',
    () async {
      final result = await useCase.execute(params, traceId: traceId);

      expect(result, const AppResult<Null>.success(null));
    },
  );

  test(
    'returns AppResult.failure and not save Account '
    'when AuthRepository.getCurrentUserId failed',
    () async {
      when(
        () => mockAuthRepository.getCurrentUserId(traceId: traceId),
      ).thenAnswer(
        (_) async => AppResult.failure(AppException.test()),
      );

      final result = await useCase.execute(params, traceId: traceId);

      expect(result, AppResult<Null>.failure(AppException.test()));
      verifyZeroInteractions(mockAccountRepository);
    },
  );

  test(
    'return AppResult.failure and not save Account '
    'when AccountRepository.getChildrenCountByParentCode failed',
    () async {
      when(
        () => mockAccountRepository.getChildrenCountByParentCode(
          userId: userId,
          parentCode: any<String>(named: 'parentCode'),
          traceId: traceId,
        ),
      ).thenAnswer(
        (_) async => AppResult<int>.failure(AppException.test()),
      );

      final result = await useCase.execute(params, traceId: traceId);

      expect(result, AppResult<Null>.failure(AppException.test()));
      verify(
        () => mockAccountRepository.getChildrenCountByParentCode(
          userId: userId,
          parentCode: '10.0000',
          traceId: traceId,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockAccountRepository);
    },
  );

  test(
    'return AppResult.failure '
    'when AccountRepository.save failed',
    () async {
      when(
        () => mockAccountRepository.save(
          any<String>(),
          any<Account>(),
          traceId: traceId,
        ),
      ).thenAnswer(
        (_) async => AppResult.failure(AppException.test()),
      );

      final result = await useCase.execute(params, traceId: traceId);

      expect(result, AppResult<Null>.failure(AppException.test()));
      verify(
        () => mockAccountRepository.getChildrenCountByParentCode(
          userId: userId,
          parentCode: '10.0000',
          traceId: traceId,
        ),
      ).called(1);
      verify(
        () => mockAccountRepository.save(
          userId,
          any<Account>(),
          traceId: traceId,
        ),
      ).called(1);
    },
  );
}
