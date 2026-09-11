import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/repositories/i_wallet_respository.dart';
import 'package:journexa_app/domain/use_cases/wallet/watch_wallets.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mocktail/mocktail.dart';

class MockWalletRepository extends Mock implements IWalletRepository {}

void main() {
  const traceId = 'traceId';
  const expectedParentCode = '10.0000';
  final parent = Account(
    code: expectedParentCode,
    name: 'asset',
    type: AccountType.asset,
    isSystemAccount: true,
  );
  final accounts = List.generate(
    5,
    (idx) => Account(
      code: '10.000${idx + 1}',
      name: 'asset $idx',
      type: parent.type,
      parent: parent,
    ),
  );
  final wallets = accounts
      .map(
        (it) => Wallet(
          id: it.code,
          name: it.name,
          account: it,
        ),
      )
      .toList();

  late IWalletRepository mockWalletRepository;
  late WatchWalletsUseCase useCase;

  setUp(() {
    mockWalletRepository = MockWalletRepository();
    when(
      () => mockWalletRepository.watch(
        traceId: traceId,
        query: any(named: 'query'),
        isDeleted: any(named: 'isDeleted'),
      ),
    ).thenAnswer((_) => Stream.value(AppResult.success(wallets)));

    useCase = WatchWalletsUseCase(
      walletRepository: mockWalletRepository,
    );
  });

  test(
    'calls WalletRepository.watch once '
    'with correct args',
    () async {
      final result = useCase.execute(
        const WatchWalletsParams(),
        traceId: traceId,
      );
      await result.first;

      verify(
        () => mockWalletRepository.watch(
          traceId: traceId,
          isDeleted: false,
        ),
      ).called(1);
    },
  );

  test(
    'calls WalletRepository.watch once '
    'with correct args when query provided',
    () async {
      final result = useCase.execute(
        const WatchWalletsParams(query: 'query'),
        traceId: traceId,
      );
      await result.first;

      verify(
        () => mockWalletRepository.watch(
          traceId: traceId,
          query: 'query',
          isDeleted: false,
        ),
      ).called(1);
    },
  );

  test(
    'emits correct map of wallet code to its balance '
    'when all operations are successful',
    () async {
      final result = useCase.execute(
        const WatchWalletsParams(),
        traceId: traceId,
      );

      expect(
        result,
        emits(AppResult.success(wallets)),
      );
    },
  );

  test(
    'emits failure '
    'when WalletRepository.watch emits failure',
    () async {
      when(
        () => mockWalletRepository.watch(
          traceId: traceId,
          isDeleted: false,
        ),
      ).thenAnswer((_) => Stream.value(AppResult.failure(AppException.test())));

      final result = useCase.execute(
        const WatchWalletsParams(),
        traceId: traceId,
      );

      expect(
        result,
        emits(AppResult<List<Wallet>>.failure(AppException.test())),
      );
    },
  );
}
