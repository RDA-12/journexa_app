import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/use_cases/account/initialize_accounts.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';
import 'package:journexa_app/ui/initialize/bloc/initialize_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockInitializeAccountsUseCase extends Mock
    implements InitializeAccountsUseCase {}

class MockUidGenerator extends Mock implements UidGenerator {}

void main() {
  const traceId = 'traceId';
  late InitializeAccountsUseCase mockInitializeAccounts;
  late UidGenerator mockUidGenerator;

  setUp(() {
    mockUidGenerator = MockUidGenerator();
    mockInitializeAccounts = MockInitializeAccountsUseCase();
    when(mockUidGenerator.generateUid).thenReturn(traceId);
    when(
      () => mockInitializeAccounts.execute(
        const NoParams(),
        traceId: traceId,
      ),
    ).thenAnswer(
      (_) async => const AppResult.success(null),
    );
  });

  InitializeBloc buildBloc() {
    return InitializeBloc(
      uidGenerator: mockUidGenerator,
      initializeAccounts: mockInitializeAccounts,
    );
  }

  tearDown(() {
    reset(mockUidGenerator);
    reset(mockInitializeAccounts);
  });

  test('have initial state of InitializeState.initial', () {
    final bloc = buildBloc();

    expect(bloc.state, const InitializeState.initial());
  });

  group('InitializeEvent.initialize', () {
    blocTest<InitializeBloc, InitializeState>(
      'emits [InitializeState.loading, InitializeState.initialized] '
      'when initilize accounts succeeded',
      build: buildBloc,
      act: (bloc) => bloc.add(const InitializeEvent.initialize()),
      expect: () => const <InitializeState>[
        InitializeState.loading(),
        InitializeState.initialized(),
      ],
      verify: (_) {
        verify(mockUidGenerator.generateUid).called(1);
        verify(
          () => mockInitializeAccounts.execute(
            const NoParams(),
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<InitializeBloc, InitializeState>(
      'emits [IniializeState.loading, InitializeState.failure] '
      'when initializeAccounts failed',
      setUp: () {
        when(
          () => mockInitializeAccounts.execute(
            const NoParams(),
            traceId: traceId,
          ),
        ).thenAnswer(
          (_) async => AppResult.failure(AppException.test()),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const InitializeEvent.initialize()),
      expect: () => <InitializeState>[
        const InitializeState.loading(),
        InitializeState.failure(AppException.test()),
      ],
      verify: (_) {
        verify(mockUidGenerator.generateUid).called(1);
        verify(
          () => mockInitializeAccounts.execute(
            const NoParams(),
            traceId: traceId,
          ),
        ).called(1);
      },
    );
  });
}
