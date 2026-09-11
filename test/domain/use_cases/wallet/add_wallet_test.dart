import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/repositories/i_account_repository.dart';
import 'package:journexa_app/domain/repositories/i_wallet_respository.dart';
import 'package:journexa_app/domain/use_cases/wallet/add_wallet.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';
import 'package:mocktail/mocktail.dart';

class MockAccountRepository extends Mock implements IAccountRepository {}

class MockWalletRepository extends Mock implements IWalletRepository {}

class MockUidGenerator extends Mock implements UidGenerator {}

void main() {
  const traceId = 'trace';
  const walletId = 'walletId';
  const currentChildrenCount = 10;
  const params = AddWalletParams(
    name: 'my wallet',
  );

  late IAccountRepository mockAccountRepository;
  late IWalletRepository mockWalletRepository;
  late UidGenerator mockUidGenerator;
  late AddWalletUseCase useCase;

  setUpAll(() {
    registerFallbackValue(Account.test());
    registerFallbackValue(Wallet.test());
  });

  setUp(() {
    mockAccountRepository = MockAccountRepository();
    when(
      () => mockAccountRepository.getChildrenCountByParentCode(
        parentCode: any<String>(named: 'parentCode'),
        traceId: traceId,
      ),
    ).thenAnswer(
      (_) async => const AppResult.success(currentChildrenCount),
    );

    mockWalletRepository = MockWalletRepository();
    when(
      () => mockWalletRepository.save(
        wallet: any<Wallet>(named: 'wallet'),
        traceId: traceId,
      ),
    ).thenAnswer(
      (_) async => const AppResult.success(null),
    );

    mockUidGenerator = MockUidGenerator();
    when(mockUidGenerator.generateUid).thenReturn(walletId);

    useCase = AddWalletUseCase(
      accountRepository: mockAccountRepository,
      walletRepository: mockWalletRepository,
    )..customGenerator = mockUidGenerator;
  });

  test(
    'calls AccountRepository.getChildrenCountByParentCode once '
    'to get current asset account children count',
    () async {
      await useCase.execute(params, traceId: traceId);

      verify(
        () => mockAccountRepository.getChildrenCountByParentCode(
          parentCode: SystemDefinedAccount.walletParent.code.value,
          traceId: traceId,
        ),
      ).called(1);
    },
  );

  test(
    'calls WalletRepository.save once '
    'with correct Account',
    () async {
      final expectedAccount = Account.sub(
        parent: SystemDefinedAccount.walletParent,
        name: params.name,
        currentChildrenCount: currentChildrenCount,
      );
      final expected = Wallet(
        id: walletId,
        name: params.name,
        account: expectedAccount,
      );

      await useCase.execute(params, traceId: traceId);

      verify(
        () => mockWalletRepository.save(
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
    'return AppResult.failure and not save Wallet '
    'when AccountRepository.getChildrenCountByParentCode failed',
    () async {
      when(
        () => mockAccountRepository.getChildrenCountByParentCode(
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
          parentCode: SystemDefinedAccount.walletParent.code.value,
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
          parentCode: SystemDefinedAccount.walletParent.code.value,
          traceId: traceId,
        ),
      ).called(1);
      verify(
        () => mockWalletRepository.save(
          wallet: any<Wallet>(named: 'wallet'),
          traceId: traceId,
        ),
      ).called(1);
    },
  );
}
