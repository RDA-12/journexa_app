import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/use_cases/auth/check_auth.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';
import 'package:journexa_app/ui/splash/bloc/auth_check_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockCheckAuthUseCase extends Mock implements CheckAuthUseCase {}

class MockUidGenerator extends Mock implements UidGenerator {}

void main() {
  const traceId = 'trace';

  late UidGenerator mockUidGenerator;
  late CheckAuthUseCase mockCheckAuthUseCase;

  setUp(() {
    mockUidGenerator = MockUidGenerator();
    when(() => mockUidGenerator.generateUid()).thenReturn(traceId);
    mockCheckAuthUseCase = MockCheckAuthUseCase();
    when(
      () => mockCheckAuthUseCase.execute(const NoParams(), traceId: traceId),
    ).thenAnswer((_) async => const AppResult.success(true));
  });

  AuthCheckBloc buildBloc() {
    return AuthCheckBloc(
      checkAuth: mockCheckAuthUseCase,
    )..customGenerator = mockUidGenerator;
  }

  test(
    'initial state is AuthCheckState.initial',
    () {
      final bloc = buildBloc();

      expect(bloc.state, const AuthCheckState.initial());
    },
  );

  group('AuthCheckEvent.started', () {
    blocTest<AuthCheckBloc, AuthCheckState>(
      'emits [AuthCheckState.loading, AuthCheckState.authenticated] '
      'when auth check succeeded and user already logged in',
      build: buildBloc,
      act: (bloc) => bloc.add(const AuthCheckEvent.started()),
      expect: () => const <AuthCheckState>[
        AuthCheckState.loading(),
        AuthCheckState.authenticated(),
      ],
      verify: (_) {
        verify(
          () =>
              mockCheckAuthUseCase.execute(const NoParams(), traceId: traceId),
        ).called(1);
        verify(mockUidGenerator.generateUid).called(1);
      },
    );

    blocTest<AuthCheckBloc, AuthCheckState>(
      'emits [AuthCheckState.loading, AuthCheckState.unauthenticated] '
      'when auth check succeeded and user not logged in yet',
      setUp: () {
        when(
          () => mockCheckAuthUseCase.execute(
            const NoParams(),
            traceId: traceId,
          ),
        ).thenAnswer((_) async => const AppResult.success(false));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const AuthCheckEvent.started()),
      expect: () => const <AuthCheckState>[
        AuthCheckState.loading(),
        AuthCheckState.unauthenticated(),
      ],
      verify: (_) {
        verify(
          () =>
              mockCheckAuthUseCase.execute(const NoParams(), traceId: traceId),
        ).called(1);
        verify(mockUidGenerator.generateUid).called(1);
      },
    );

    blocTest<AuthCheckBloc, AuthCheckState>(
      'emits [AuthCheckState.loading, AuthCheckState.failure] '
      'when auth check failed',
      setUp: () {
        when(
          () => mockCheckAuthUseCase.execute(
            const NoParams(),
            traceId: traceId,
          ),
        ).thenAnswer((_) async => AppResult<bool>.failure(AppException.test()));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const AuthCheckEvent.started()),
      expect: () => <AuthCheckState>[
        const AuthCheckState.loading(),
        AuthCheckState.failure(AppException.test()),
      ],
      verify: (_) {
        verify(
          () => mockCheckAuthUseCase.execute(
            const NoParams(),
            traceId: traceId,
          ),
        ).called(1);
        verify(mockUidGenerator.generateUid).called(1);
      },
    );
  });
}
