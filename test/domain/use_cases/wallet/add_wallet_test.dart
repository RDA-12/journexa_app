import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/repositories/i_account_repository.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/repositories/i_wallet_respository.dart';
import 'package:journexa_app/domain/use_cases/wallet/add_wallet.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

class MockAccountRepository extends Mock implements IAccountRepository {}

class MockWalletRepository extends Mock implements IWalletRepository {}

class MockUidGenerator extends Mock implements UidGenerator {}

void main() {
  const traceId = 'trace';
  const userId = 'userId';
  const walletId = 'walletId';
  const currentChildrenCount = 10;
  const nextCode = '10.0011';
  const params = AddWalletParams(
    name: 'my wallet',
  );

  late IAuthRepository mockAuthRepository;
  late IAccountRepository mockAccountRepository;
  late IWalletRepository mockWalletRepository;
  late UidGenerator mockUidGenerator;
  late AddWalletUseCase useCase;

  setUpAll(() {
    registerFallbackValue(Account.test());
    registerFallbackValue(Wallet.test());
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

    mockWalletRepository = MockWalletRepository();
    when(
      () => mockWalletRepository.save(
        userId: any<String>(named: 'userId'),
        wallet: any<Wallet>(named: 'wallet'),
        traceId: traceId,
      ),
    ).thenAnswer(
      (_) async => const AppResult.success(null),
    );

    mockUidGenerator = MockUidGenerator();
    when(mockUidGenerator.generateUid).thenReturn(walletId);

    useCase = AddWalletUseCase(
      authRepository: mockAuthRepository,
      accountRepository: mockAccountRepository,
      walletRepository: mockWalletRepository,
    )..customGenerator = mockUidGenerator;
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
    'calls WalletRepository.save once '
    'with correct userId and Account',
    () async {
      final expectedAccount = Account(
        code: nextCode,
        name: params.name,
        type: AccountType.asset,
        parent: SystemDefinedAccount.rootAsset,
      );
      final expected = Wallet(
        id: walletId,
        name: params.name,
        account: expectedAccount,
      );

      await useCase.execute(params, traceId: traceId);

      verify(
        () => mockWalletRepository.save(
          userId: userId,
          wallet: expected,
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
    'returns AppResult.failure and not save Wallet '
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
      verifyZeroInteractions(mockWalletRepository);
    },
  );

  test(
    'return AppResult.failure and not save Wallet '
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
      verifyZeroInteractions(mockWalletRepository);
    },
  );

  test(
    'return AppResult.failure '
    'when WalletRepository.save failed',
    () async {
      when(
        () => mockWalletRepository.save(
          userId: any<String>(named: 'userId'),
          wallet: any<Wallet>(named: 'wallet'),
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
        () => mockWalletRepository.save(
          userId: userId,
          wallet: any<Wallet>(named: 'wallet'),
          traceId: traceId,
        ),
      ).called(1);
    },
  );
}
