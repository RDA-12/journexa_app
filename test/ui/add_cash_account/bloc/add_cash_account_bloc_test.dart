import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/use_cases/account/add_cash_account.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';
import 'package:journexa_app/ui/add_cash_account/bloc/add_cash_account_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockAddCashAccountUseCase extends Mock implements AddCashAccountUseCase {}

class MockUidGenerator extends Mock implements UidGenerator {}

void main() {
  const traceId = 'trace';
  const params = AddCashAccountParams(name: 'Test');

  late AddCashAccountUseCase mockAddCashAccount;
  late UidGenerator mockUidGenerator;

  setUpAll(() {
    registerFallbackValue(params);
  });

  setUp(() {
    mockAddCashAccount = MockAddCashAccountUseCase();
    when(
      () => mockAddCashAccount.execute(
        any<AddCashAccountParams>(),
        traceId: traceId,
      ),
    ).thenAnswer((_) async => const AppResult.success(null));
    mockUidGenerator = MockUidGenerator();
    when(() => mockUidGenerator.generateUid()).thenReturn(traceId);
  });

  AddCashAccountBloc buildBloc() {
    return AddCashAccountBloc(
      addCashAccount: mockAddCashAccount,
      uidGenerator: mockUidGenerator,
    );
  }

  test('Initial state should be AddCashAccountState.initial', () {
    expect(buildBloc().state, const AddCashAccountState.initial());
  });

  group('submit', () {
    blocTest<AddCashAccountBloc, AddCashAccountState>(
      'emits [AddCashAccountState.loading, AddCashAccountState.added] '
      'when add cash account succeeded',
      build: buildBloc,
      act: (bloc) => bloc.add(AddCashAccountEvent.submit(name: params.name)),
      expect: () => const <AddCashAccountState>[
        AddCashAccountState.loading(),
        AddCashAccountState.added(),
      ],
      verify: (_) {
        verify(
          () => mockAddCashAccount.execute(params, traceId: traceId),
        ).called(1);
      },
    );

    blocTest<AddCashAccountBloc, AddCashAccountState>(
      'emits [AddCashAccountState.loading, AddCashAccountState.failure] '
      'when add cash account failed',
      setUp: () {
        when(
          () => mockAddCashAccount.execute(params, traceId: traceId),
        ).thenAnswer(
          (_) async => AppResult<Null>.failure(AppException.test()),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(AddCashAccountEvent.submit(name: params.name)),
      expect: () => <AddCashAccountState>[
        const AddCashAccountState.loading(),
        AddCashAccountState.failure(AppException.test()),
      ],
      verify: (_) {
        verify(
          () => mockAddCashAccount.execute(params, traceId: traceId),
        ).called(1);
      },
    );
  });
}
