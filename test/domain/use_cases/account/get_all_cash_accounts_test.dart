import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/journal.dart';
import 'package:journexa_app/domain/repositories/i_account_repository.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/repositories/i_journal_repository.dart';
import 'package:journexa_app/domain/use_cases/account/get_all_cash_accounts.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mocktail/mocktail.dart';

class MockAccountRepository extends Mock implements IAccountRepository {}

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
  final accountBalancesMap = Map<String, AccountBalance>.fromIterable(
    accounts.map(
      (it) => AccountBalance(
        account: it,
        balance: Decimal.fromInt(10),
      ),
    ),
    key: (it) => (it as AccountBalance).account.code,
  );
  final accountBalances = accountBalancesMap.values.toList();

  late IAuthRepository mockAuthRepository;
  late IAccountRepository mockAccountRepository;
  late IJournalRepository mockJournalRepository;
  late GetAllCashAccountsUseCase useCase;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    when(
      () => mockAuthRepository.getCurrentUserId(traceId: traceId),
    ).thenAnswer((_) async => const AppResult.success(userId));

    mockAccountRepository = MockAccountRepository();
    when(
      () => mockAccountRepository.getByParentCode(
        userId: userId,
        parentCode: expectedParentCode,
        traceId: traceId,
      ),
    ).thenAnswer((_) async => AppResult.success(accounts));

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

    useCase = GetAllCashAccountsUseCase(
      authRepository: mockAuthRepository,
      accountRepository: mockAccountRepository,
      journalRepository: mockJournalRepository,
    );
  });

  test(
    'calls AuthRepository.getCurrentUserId once '
    'to get current user id',
    () async {
      await useCase.execute(traceId: traceId);

      verify(
        () => mockAuthRepository.getCurrentUserId(traceId: traceId),
      ).called(1);
    },
  );

  test(
    'calls AccountRepository.getByParentCode once '
    'with correct args',
    () async {
      await useCase.execute(traceId: traceId);

      verify(
        () => mockAccountRepository.getByParentCode(
          userId: userId,
          parentCode: expectedParentCode,
          traceId: traceId,
        ),
      ).called(1);
    },
  );

  test(
    'calls JournalRepository.getCurrentBalance once '
    'with correct args',
    () async {
      await useCase.execute(traceId: traceId);

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
      final result = await useCase.execute(traceId: traceId);

      expect(
        result,
        AppResult.success(accountBalances),
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

      final result = await useCase.execute(traceId: traceId);

      expect(
        result,
        AppResult<List<AccountBalance>>.failure(
          AppException.test(),
        ),
      );
      verifyZeroInteractions(mockAccountRepository);
    },
  );

  test(
    'returns failure '
    'when AccountRepository.getByParentCode failed',
    () async {
      when(
        () => mockAccountRepository.getByParentCode(
          userId: userId,
          parentCode: expectedParentCode,
          traceId: traceId,
        ),
      ).thenAnswer((_) async => AppResult.failure(AppException.test()));

      final result = await useCase.execute(traceId: traceId);

      expect(
        result,
        AppResult<List<AccountBalance>>.failure(AppException.test()),
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

      final result = await useCase.execute(traceId: traceId);

      expect(
        result,
        AppResult<List<AccountBalance>>.failure(AppException.test()),
      );
    },
  );
}
