import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/repositories/i_wallet_respository.dart';
import 'package:journexa_app/domain/use_cases/wallet/delete_wallet.dart';
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
    name: 'asset',
    account: Account(
      code: '10.0001',
      name: 'asset',
      type: AccountType.asset,
    ),
  );
  final params = DeleteWalletParams(wallet: wallet);

  late IAuthRepository mockAuthRepository;
  late IWalletRepository mockWalletRepository;
  late DeleteWalletUseCase useCase;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    when(
      () => mockAuthRepository.getCurrentUserId(traceId: traceId),
    ).thenAnswer((_) async => const AppResult.success(userId));

    mockWalletRepository = MockWalletRepository();
    when(
      () => mockWalletRepository.delete(
        userId: userId,
        wallet: params.wallet,
        traceId: traceId,
      ),
    ).thenAnswer((_) async => const AppResult.success(null));

    useCase = DeleteWalletUseCase(
      authRepository: mockAuthRepository,
      walletRepository: mockWalletRepository,
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
    'calls WalletRepository.delete once '
    'with correct args',
    () async {
      await useCase.execute(params, traceId: traceId);

      verify(
        () => mockWalletRepository.delete(
          userId: userId,
          wallet: params.wallet,
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
    'and not call WalletRepository.deleteByCode',
    () async {
      when(
        () => mockAuthRepository.getCurrentUserId(traceId: traceId),
      ).thenAnswer((_) async => AppResult.failure(AppException.test()));

      final result = await useCase.execute(params, traceId: traceId);

      expect(result, AppResult<Null>.failure(AppException.test()));
      verifyZeroInteractions(mockWalletRepository);
    },
  );

  test(
    'returns failure when WalletRepository.delete failed',
    () async {
      when(
        () => mockWalletRepository.delete(
          userId: userId,
          wallet: params.wallet,
          traceId: traceId,
        ),
      ).thenAnswer((_) async => AppResult.failure(AppException.test()));

      final result = await useCase.execute(params, traceId: traceId);

      expect(result, AppResult<Null>.failure(AppException.test()));
    },
  );
}
