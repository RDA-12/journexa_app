import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/repositories/i_journal_repository.dart';
import 'package:journexa_app/domain/repositories/i_wallet_respository.dart';
import 'package:journexa_app/domain/use_cases/wallet/watch_wallets.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mocktail/mocktail.dart';

class MockWalletRepository extends Mock implements IWalletRepository {}

class MockAuthRepository extends Mock implements IAuthRepository {}

class MockJournalRepository extends Mock implements IJournalRepository {}

void main() {
  const userId = 'userId';
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
  final accountBalancesMap = {
    for (final it in accounts) it.code: Decimal.fromInt(10),
  };
  final walletWithBalance = wallets.map((it) {
    final balance = accountBalancesMap[it.account.code] ?? Decimal.zero;
    return WalletWithBalance(wallet: it, balance: balance);
  }).toList();

  late IAuthRepository mockAuthRepository;
  late IJournalRepository mockJournalRepository;
  late IWalletRepository mockWalletRepository;
  late WatchWalletsUseCase useCase;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    when(
      () => mockAuthRepository.getCurrentUserId(traceId: traceId),
    ).thenAnswer((_) async => const AppResult.success(userId));

    mockWalletRepository = MockWalletRepository();
    when(
      () => mockWalletRepository.watch(
        userId: userId,
        traceId: traceId,
        query: any(named: 'query'),
        isDeleted: any(named: 'isDeleted'),
      ),
    ).thenAnswer((_) => Stream.value(AppResult.success(wallets)));

    mockJournalRepository = MockJournalRepository();
    when(
      () => mockJournalRepository.watchCurrentBalance(
        userId: userId,
        traceId: traceId,
      ),
    ).thenAnswer(
      (_) => Stream.value(AppResult.success(accountBalancesMap)),
    );

    useCase = WatchWalletsUseCase(
      authRepository: mockAuthRepository,
      walletRepository: mockWalletRepository,
      journalRepository: mockJournalRepository,
    );
  });

  test(
    'calls AuthRepository.getCurrentUserId once '
    'to get current user id',
    () async {
      final result = useCase.execute(
        const WatchWalletsParams(),
        traceId: traceId,
      );
      await result.first;

      verify(
        () => mockAuthRepository.getCurrentUserId(traceId: traceId),
      ).called(1);
    },
  );

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
          userId: userId,
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
          userId: userId,
          traceId: traceId,
          query: 'query',
          isDeleted: false,
        ),
      ).called(1);
    },
  );

  test(
    'calls JournalRepository.watchCurrentBalance once '
    'with correct args',
    () async {
      final result = useCase.execute(
        const WatchWalletsParams(),
        traceId: traceId,
      );
      await result.first;

      verify(
        () => mockJournalRepository.watchCurrentBalance(
          userId: userId,
          traceId: traceId,
        ),
      ).called(1);
    },
  );

  test(
    'emits correct AccountBalances when all operations are successful',
    () async {
      final result = useCase.execute(
        const WatchWalletsParams(),
        traceId: traceId,
      );

      expect(
        result,
        emits(AppResult.success(walletWithBalance)),
      );
    },
  );

  test(
    'emits failure and not fetch Accounts '
    'when AuthRepository.getCurrentUserId failed',
    () async {
      when(
        () => mockAuthRepository.getCurrentUserId(traceId: traceId),
      ).thenAnswer((_) async => AppResult<String>.failure(AppException.test()));

      final result = useCase.execute(
        const WatchWalletsParams(),
        traceId: traceId,
      );

      expect(
        result,
        emits(
          AppResult<List<WalletWithBalance>>.failure(
            AppException.test(),
          ),
        ),
      );
      verifyZeroInteractions(mockWalletRepository);
    },
  );

  test(
    'emits failure '
    'when WalletRepository.watch emits failure',
    () async {
      when(
        () => mockWalletRepository.watch(
          userId: userId,
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
        emits(AppResult<List<WalletWithBalance>>.failure(AppException.test())),
      );
    },
  );

  test(
    'emits failure '
    'when JournalRepository.watchCurrentBalance emits failure',
    () async {
      when(
        () => mockJournalRepository.watchCurrentBalance(
          userId: userId,
          traceId: traceId,
        ),
      ).thenAnswer(
        (_) => Stream.value(
          AppResult<Map<String, Decimal>>.failure(
            AppException.test(),
          ),
        ),
      );

      final result = useCase.execute(
        const WatchWalletsParams(),
        traceId: traceId,
      );

      expect(
        result,
        emits(AppResult<List<WalletWithBalance>>.failure(AppException.test())),
      );
    },
  );
}
