import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/repositories/i_wallet_respository.dart';
import 'package:journexa_app/domain/use_cases/wallet/update_wallet.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mocktail/mocktail.dart';

class MockWalletRepository extends Mock implements IWalletRepository {}

void main() {
  const traceId = 'traceId';
  final wallet = Wallet(
    id: 'id',
    name: 'asset 1',
    account: Account.sub(
      name: 'asset 1',
      parent: SystemDefinedAccount.walletParent,
      currentChildrenCount: 0,
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

  late IWalletRepository mockWalletRepository;
  late UpdateWalletUseCase useCase;

  setUpAll(() {
    registerFallbackValue(updatedWallet);
  });

  setUp(() {
    mockWalletRepository = MockWalletRepository();
    when(
      () => mockWalletRepository.update(
        updatedWallet: updatedWallet,
        traceId: traceId,
      ),
    ).thenAnswer((_) async => const AppResult.success(null));

    useCase = UpdateWalletUseCase(
      walletRepository: mockWalletRepository,
    );
  });

  test(
    'calls WalletRepository.update once '
    'to save updated wallet',
    () async {
      await useCase.execute(params, traceId: traceId);

      verify(
        () => mockWalletRepository.update(
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
    'returns failure '
    'when WalletRepository.update failed',
    () async {
      when(
        () => mockWalletRepository.update(
          updatedWallet: updatedWallet,
          traceId: traceId,
        ),
      ).thenAnswer((_) async => AppResult<Null>.failure(AppException.test()));

      final result = await useCase.execute(params, traceId: traceId);

      expect(result, AppResult<Wallet>.failure(AppException.test()));
    },
  );
}
