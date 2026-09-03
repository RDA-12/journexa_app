import 'package:bloc_test/bloc_test.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/use_cases/transaction/add_income.dart';
import 'package:journexa_app/domain/use_cases/transaction/transfer_money.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';
import 'package:journexa_app/ui/transactions/bloc/add_transaction_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockUidGenerator extends Mock implements UidGenerator {}

class MockTransferMoneyUseCase extends Mock implements TransferMoneyUseCase {}

class MockAddIncomeUseCase extends Mock implements AddIncomeUseCase {}

void main() {
  const traceId = 'traceId';
  final transferTransaction = TransferTransaction(
    id: 'id',
    source: Wallet.test(),
    destination: Wallet.test().update(name: 'wallet 2').copyWith(id: 'w-2'),
    amount: Decimal.fromInt(1000),
    fee: Decimal.zero,
    date: DateTime.now(),
  );
  final incomeTransaction = IncomeTransaction(
    id: 'id',
    wallet: Wallet.test(),
    category: IncomeCategory.test(),
    amount: Decimal.fromInt(1000),
    date: DateTime.now(),
  );

  late UidGenerator mockUidGenerator;
  late TransferMoneyUseCase mockTransferMoney;
  late AddIncomeUseCase mockAddIncome;

  setUpAll(() {
    registerFallbackValue(
      TransferMoneyParams(
        source: Wallet.test(),
        destination: Wallet.test(),
        amount: Decimal.zero,
        fee: Decimal.zero,
        date: DateTime.now(),
      ),
    );
    registerFallbackValue(
      AddIncomeParams(
        wallet: Wallet.test(),
        category: IncomeCategory.test(),
        amount: Decimal.zero,
        date: DateTime.now(),
      ),
    );
  });

  setUp(() {
    mockUidGenerator = MockUidGenerator();
    when(mockUidGenerator.generateUid).thenAnswer((_) => traceId);

    mockTransferMoney = MockTransferMoneyUseCase();
    when(() => mockTransferMoney.execute(any(), traceId: traceId)).thenAnswer(
      (_) async => AppResult.success(transferTransaction),
    );

    mockAddIncome = MockAddIncomeUseCase();
    when(() => mockAddIncome.execute(any(), traceId: traceId)).thenAnswer(
      (_) async => AppResult.success(incomeTransaction),
    );
  });

  AddTransactionBloc buildBloc() {
    return AddTransactionBloc(
      transferMoney: mockTransferMoney,
      addIncome: mockAddIncome,
    )..customGenerator = mockUidGenerator;
  }

  test('has initial state initially', () {
    final bloc = buildBloc();
    expect(bloc.state, const AddTransactionState.initial());
  });

  group('transfer', () {
    final params = TransferMoneyParams(
      source: Wallet.test(),
      destination: Wallet.test(),
      amount: Decimal.zero,
      fee: Decimal.zero,
      date: DateTime.now(),
      notes: 'notes',
    );

    blocTest<AddTransactionBloc, AddTransactionState>(
      'emits [AddTransactionState.Loading, AddTransactionState.Added] '
      'when transfer is successful.',
      build: buildBloc,
      act: (bloc) => bloc.add(
        AddTransactionEvent.transfer(
          source: params.source,
          destination: params.destination,
          amount: params.amount,
          fee: params.fee,
          date: params.date,
          notes: params.notes,
        ),
      ),
      expect: () => <AddTransactionState>[
        const AddTransactionState.loading(),
        AddTransactionState.added(transferTransaction),
      ],
      verify: (_) {
        verify(
          () => mockTransferMoney.execute(
            params,
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<AddTransactionBloc, AddTransactionState>(
      'emits [AddTransactionState.Loading, AddTransactionState.Failure] '
      'when transfer is failed.',
      setUp: () {
        when(
          () => mockTransferMoney.execute(any(), traceId: traceId),
        ).thenAnswer(
          (_) async => AppResult.failure(AppException.test()),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        AddTransactionEvent.transfer(
          source: params.source,
          destination: params.destination,
          amount: params.amount,
          fee: params.fee,
          date: params.date,
          notes: params.notes,
        ),
      ),
      expect: () => <AddTransactionState>[
        const AddTransactionState.loading(),
        AddTransactionState.failure(AppException.test()),
      ],
      verify: (_) {
        verify(
          () => mockTransferMoney.execute(
            params,
            traceId: traceId,
          ),
        ).called(1);
      },
    );
  });

  group('income', () {
    final params = AddIncomeParams(
      wallet: Wallet.test(),
      category: IncomeCategory.test(),
      amount: Decimal.fromInt(1000),
      date: DateTime.now(),
      notes: 'notes',
    );

    blocTest<AddTransactionBloc, AddTransactionState>(
      'emits [AddTransactionState.Loading, AddTransactionState.Added] '
      'when income is successful.',
      build: buildBloc,
      act: (bloc) => bloc.add(
        AddTransactionEvent.income(
          wallet: params.wallet,
          category: params.category,
          amount: params.amount,
          date: params.date,
          notes: params.notes,
        ),
      ),
      expect: () => <AddTransactionState>[
        const AddTransactionState.loading(),
        AddTransactionState.added(incomeTransaction),
      ],
      verify: (_) {
        verify(
          () => mockAddIncome.execute(
            params,
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<AddTransactionBloc, AddTransactionState>(
      'emits [AddTransactionState.Loading, AddTransactionState.Failure] '
      'when income is failed.',
      setUp: () {
        when(
          () => mockAddIncome.execute(any(), traceId: traceId),
        ).thenAnswer(
          (_) async => AppResult.failure(AppException.test()),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        AddTransactionEvent.income(
          wallet: params.wallet,
          category: params.category,
          amount: params.amount,
          date: params.date,
          notes: params.notes,
        ),
      ),
      expect: () => <AddTransactionState>[
        const AddTransactionState.loading(),
        AddTransactionState.failure(AppException.test()),
      ],
      verify: (_) {
        verify(
          () => mockAddIncome.execute(
            params,
            traceId: traceId,
          ),
        ).called(1);
      },
    );
  });
}
