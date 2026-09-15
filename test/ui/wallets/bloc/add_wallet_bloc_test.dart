import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/use_cases/wallet/add_wallet.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';
import 'package:journexa_app/ui/wallets/bloc/add_wallet_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockAddWalletUseCase extends Mock implements AddWalletUseCase;

class MockUidGenerator extends Mock implements UidGenerator;

void main() {
  const traceId = 'trace';
  const params = AddWalletParams(name: 'Test');

  late AddWalletUseCase mockAddWallet;
  late UidGenerator mockUidGenerator;

  setUpAll(() {
    registerFallbackValue(params);
  });

  setUp(() {
    mockAddWallet = MockAddWalletUseCase();
    when(
      () => mockAddWallet.execute(
        any<AddWalletParams>(),
        traceId: traceId,
      ),
    ).thenAnswer((_) async => const AppResult.success(null));
    mockUidGenerator = MockUidGenerator();
    when(() => mockUidGenerator.generateUid()).thenReturn(traceId);
  });

  AddWalletBloc buildBloc() {
    return AddWalletBloc(
      addWallet: mockAddWallet,
    )..customGenerator = mockUidGenerator;
  }

  test('Initial state should be AddWalletState.initial', () {
    expect(buildBloc().state, const AddWalletState.initial());
  });

  group('submit', () {
    blocTest<AddWalletBloc, AddWalletState>(
      'emits [AddWalletState.loading, AddWalletState.added] '
      'when add wallet succeeded',
      build: buildBloc,
      act: (bloc) => bloc.add(AddWalletEvent.submit(name: params.name)),
      expect: () => const <AddWalletState>[
        AddWalletState.loading(),
        AddWalletState.added(),
      ],
      verify: (_) {
        verify(() => mockUidGenerator.generateUid()).called(1);
        verify(
          () => mockAddWallet.execute(params, traceId: traceId),
        ).called(1);
      },
    );

    blocTest<AddWalletBloc, AddWalletState>(
      'emits [AddWalletState.loading, AddWalletState.failure] '
      'when add wallet failed',
      setUp: () {
        when(
          () => mockAddWallet.execute(params, traceId: traceId),
        ).thenAnswer(
          (_) async => AppResult<Null>.failure(AppException.test()),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(AddWalletEvent.submit(name: params.name)),
      expect: () => <AddWalletState>[
        const AddWalletState.loading(),
        AddWalletState.failure(
          AppException.test(),
          name: params.name,
        ),
      ],
      verify: (_) {
        verify(() => mockUidGenerator.generateUid()).called(1);
        verify(
          () => mockAddWallet.execute(params, traceId: traceId),
        ).called(1);
      },
    );
  });
}
