import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/repositories/i_wallet_respository.dart';
import 'package:journexa_app/domain/use_cases/wallet/delete_wallet.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mocktail/mocktail.dart';

class MockWalletRepository extends Mock implements IWalletRepository;

void main() {
  const traceId = 'traceId';
  final wallet = Wallet(
    id: 'id',
    name: 'asset',
    account: Account.sub(
      parent: SystemDefinedAccount.walletParent,
      name: 'asset',
      currentChildrenCount: 0,
    ),
  );
  final params = DeleteWalletParams(wallet: wallet);

  late IWalletRepository mockWalletRepository;
  late DeleteWalletUseCase useCase;

  setUp(() {
    mockWalletRepository = MockWalletRepository();
    when(
      () => mockWalletRepository.delete(
        wallet: params.wallet,
        traceId: traceId,
      ),
    ).thenAnswer((_) async => const AppResult.success(null));

    useCase = DeleteWalletUseCase(
      walletRepository: mockWalletRepository,
    );
  });

  test(
    'calls WalletRepository.delete once '
    'with correct args',
    () async {
      await useCase.execute(params, traceId: traceId);

      verify(
        () => mockWalletRepository.delete(
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
    'returns failure when WalletRepository.delete failed',
    () async {
      when(
        () => mockWalletRepository.delete(
          wallet: params.wallet,
          traceId: traceId,
        ),
      ).thenAnswer((_) async => AppResult.failure(AppException.test()));

      final result = await useCase.execute(params, traceId: traceId);

      expect(result, AppResult<Null>.failure(AppException.test()));
    },
  );
}
