import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/journal.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/repositories/i_journal_repository.dart';
import 'package:journexa_app/domain/repositories/i_wallet_respository.dart';
import 'package:journexa_app/domain/use_cases/wallet/get_all_wallets.dart';
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
  final accountBalancesMap = Map<String, AccountBalance>.fromIterable(
    accounts.map(
      (it) => AccountBalance(
        account: it,
        balance: Decimal.fromInt(10),
      ),
    ),
    key: (it) => (it as AccountBalance).account.code,
  );
  final walletWithBalance = wallets.map((it) {
    final balance = accountBalancesMap[it.account.code];
    if (balance == null) {
      return WalletWithBalance(wallet: it, balance: Decimal.zero);
    }
    return WalletWithBalance(wallet: it, balance: balance.balance);
  }).toList();

  late IAuthRepository mockAuthRepository;
  late IJournalRepository mockJournalRepository;
  late IWalletRepository mockWalletRepository;
  late GetAllWalletsUseCase useCase;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    when(
      () => mockAuthRepository.getCurrentUserId(traceId: traceId),
    ).thenAnswer((_) async => const AppResult.success(userId));

    mockWalletRepository = MockWalletRepository();
    when(
      () => mockWalletRepository.getAll(
        userId: userId,
        traceId: traceId,
        query: any(named: 'query'),
      ),
    ).thenAnswer((_) async => AppResult.success(wallets));

    mockJournalRepository = MockJournalRepository();
    when(
      () => mockJournalRepository.getCurrentBalance(
        userId: userId,
        accounts: accounts,
        traceId: traceId,
      ),
    ).thenAnswer(
      (_) async => AppResult.success(accountBalancesMap),
    );

    useCase = GetAllWalletsUseCase(
      authRepository: mockAuthRepository,
      walletRepository: mockWalletRepository,
      journalRepository: mockJournalRepository,
    );
  });

  test(
    'calls AuthRepository.getCurrentUserId once '
    'to get current user id',
    () async {
      await useCase.execute(
        const GetAllWalletsParams(),
        traceId: traceId,
      );

      verify(
        () => mockAuthRepository.getCurrentUserId(traceId: traceId),
      ).called(1);
    },
  );

  test(
    'calls WalletRepository.getAll once '
    'with correct args',
    () async {
      await useCase.execute(
        const GetAllWalletsParams(),
        traceId: traceId,
      );

      verify(
        () => mockWalletRepository.getAll(
          userId: userId,
          traceId: traceId,
        ),
      ).called(1);
    },
  );

  test(
    'calls WalletRepository.getAll once '
    'with correct args when query provided',
    () async {
      await useCase.execute(
        const GetAllWalletsParams(query: 'query'),
        traceId: traceId,
      );

      verify(
        () => mockWalletRepository.getAll(
          userId: userId,
          traceId: traceId,
          query: 'query',
        ),
      ).called(1);
    },
  );

  test(
    'calls JournalRepository.getCurrentBalance once '
    'with correct args',
    () async {
      await useCase.execute(
        const GetAllWalletsParams(),
        traceId: traceId,
      );

      verify(
        () => mockJournalRepository.getCurrentBalance(
          userId: userId,
          accounts: accounts,
          traceId: traceId,
        ),
      ).called(1);
    },
  );

  test(
    'returns correct AccountBalances when all operations are successful',
    () async {
      final result = await useCase.execute(
        const GetAllWalletsParams(),
        traceId: traceId,
      );

      expect(
        result,
        AppResult.success(walletWithBalance),
      );
    },
  );

  test(
    'returns failure and not fetch Accounts '
    'when AuthRepository.getCurrentUserId failed',
    () async {
      when(
        () => mockAuthRepository.getCurrentUserId(traceId: traceId),
      ).thenAnswer((_) async => AppResult<String>.failure(AppException.test()));

      final result = await useCase.execute(
        const GetAllWalletsParams(),
        traceId: traceId,
      );

      expect(
        result,
        AppResult<List<WalletWithBalance>>.failure(
          AppException.test(),
        ),
      );
      verifyZeroInteractions(mockWalletRepository);
    },
  );

  test(
    'returns failure '
    'when WalletRepository.getAll failed',
    () async {
      when(
        () => mockWalletRepository.getAll(
          userId: userId,
          traceId: traceId,
        ),
      ).thenAnswer((_) async => AppResult.failure(AppException.test()));

      final result = await useCase.execute(
        const GetAllWalletsParams(),
        traceId: traceId,
      );

      expect(
        result,
        AppResult<List<WalletWithBalance>>.failure(AppException.test()),
      );
      verifyZeroInteractions(mockJournalRepository);
    },
  );

  test(
    'returns failure '
    'when JournalRepository.getCurrentBalance failed',
    () async {
      when(
        () => mockJournalRepository.getCurrentBalance(
          userId: userId,
          accounts: accounts,
          traceId: traceId,
        ),
      ).thenAnswer(
        (_) async => AppResult<Map<String, AccountBalance>>.failure(
          AppException.test(),
        ),
      );

      final result = await useCase.execute(
        const GetAllWalletsParams(),
        traceId: traceId,
      );

      expect(
        result,
        AppResult<List<WalletWithBalance>>.failure(AppException.test()),
      );
    },
  );
}
