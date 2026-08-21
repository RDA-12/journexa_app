import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/repositories/i_wallet_respository.dart';
import 'package:journexa_app/domain/use_cases/wallet/update_wallet.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

class MockWalletRepository extends Mock implements IWalletRepository {}

void main() {
  const userId = 'userId';
  const traceId = 'traceId';
  final wallet = Wallet(
    id: 'id',
    name: 'asset 1',
    account: Account(
      code: '10.0001',
      name: 'asset 1',
      type: AccountType.asset,
      parent: kSystemDefinedAccounts.firstWhere((it) => it.code == '10.0000'),
    ),
  );
  final params = UpdateWalletParams(
    wallet: wallet,
    name: 'new name',
  );
  final updatedWallet = wallet.copyWith(
    name: params.name!,
    account: wallet.account.copyWith(name: params.name!),
  );

  late IAuthRepository mockAuthRepository;
  late IWalletRepository mockWalletRepository;
  late UpdateWalletUseCase useCase;

  setUpAll(() {
    registerFallbackValue(updatedWallet);
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    when(
      () => mockAuthRepository.getCurrentUserId(traceId: traceId),
    ).thenAnswer((_) async => const AppResult.success(userId));

    mockWalletRepository = MockWalletRepository();
    when(
      () => mockWalletRepository.update(
        userId: userId,
        updatedWallet: updatedWallet,
        traceId: traceId,
      ),
    ).thenAnswer((_) async => const AppResult.success(null));

    useCase = UpdateWalletUseCase(
      authRepository: mockAuthRepository,
      walletRepository: mockWalletRepository,
    );
  });

  test(
    'calls AuthRepository.getCurrentUserId '
    'once to get current user id',
    () async {
      await useCase.execute(params, traceId: traceId);

      verify(
        () => mockAuthRepository.getCurrentUserId(traceId: traceId),
      ).called(1);
    },
  );

  test(
    'calls WalletRepository.update once '
    'to save updated wallet',
    () async {
      await useCase.execute(params, traceId: traceId);

      verify(
        () => mockWalletRepository.update(
          userId: userId,
          updatedWallet: updatedWallet,
          traceId: traceId,
        ),
      ).called(1);
    },
  );

  test(
    'returns success with updated Wallet '
    'when all operations succeeded',
    () async {
      final result = await useCase.execute(params, traceId: traceId);

      expect(result, AppResult.success(updatedWallet));
    },
  );

  test(
    'returns failure and not saving Wallet '
    'when AuthRepository.getCurrentUserId failed',
    () async {
      when(
        () => mockAuthRepository.getCurrentUserId(
          traceId: traceId,
        ),
      ).thenAnswer((_) async => AppResult<String>.failure(AppException.test()));

      final result = await useCase.execute(params, traceId: traceId);

      expect(result, AppResult<Wallet>.failure(AppException.test()));
      verifyZeroInteractions(mockWalletRepository);
    },
  );

  test(
    'returns failure '
    'when WalletRepository.update failed',
    () async {
      when(
        () => mockWalletRepository.update(
          userId: userId,
          updatedWallet: updatedWallet,
          traceId: traceId,
        ),
      ).thenAnswer((_) async => AppResult<Null>.failure(AppException.test()));

      final result = await useCase.execute(params, traceId: traceId);

      expect(result, AppResult<Wallet>.failure(AppException.test()));
    },
  );
}
