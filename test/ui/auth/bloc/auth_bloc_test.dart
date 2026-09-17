import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/user.dart';
import 'package:journexa_app/domain/use_cases/auth/watch_user.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';
import 'package:journexa_app/ui/auth/bloc/auth_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockWatchUserUseCase extends Mock implements WatchUserUseCase;

class MockUidGenerator extends Mock implements UidGenerator;

void main() {
  const traceId = 'trace';
  const user = User(
    id: 'user-123',
    name: 'Test User',
    email: 'test@example.com',
  );

  late UidGenerator mockUidGenerator;
  late WatchUserUseCase mockWatchUser;

  setUp(() {
    mockUidGenerator = MockUidGenerator();
    when(() => mockUidGenerator.generateUid()).thenReturn(traceId);
    mockWatchUser = MockWatchUserUseCase();
    when(
      () => mockWatchUser.execute(traceId: traceId),
    ).thenAnswer((_) => Stream.value(const AppResult.success(user)));
  });

  AuthBloc buildBloc() {
    return AuthBloc(
      watchUser: mockWatchUser,
    )..customGenerator = mockUidGenerator;
  }

  test(
    'initial state is AuthState.initial',
    () {
      final bloc = buildBloc();

      expect(bloc.state, const AuthState.initial());
    },
  );

  group('AuthEvent.subscriptionRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthState.loading, AuthState.authenticated] '
      'when watch user succeeds with a valid user',
      build: buildBloc,
      act: (bloc) => bloc.add(const AuthEvent.subscriptionRequested()),
      expect: () => const <AuthState>[
        AuthState.loading(),
        AuthState.authenticated(user),
      ],
      verify: (_) {
        verify(
          () => mockWatchUser.execute(traceId: traceId),
        ).called(1);
        verify(mockUidGenerator.generateUid).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthState.loading, AuthState.unauthenticated] '
      'when watch user succeeds with null user',
      setUp: () {
        when(
          () => mockWatchUser.execute(traceId: traceId),
        ).thenAnswer((_) => Stream.value(const AppResult.success(null)));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const AuthEvent.subscriptionRequested()),
      expect: () => const <AuthState>[
        AuthState.loading(),
        AuthState.unauthenticated(),
      ],
      verify: (_) {
        verify(
          () => mockWatchUser.execute(traceId: traceId),
        ).called(1);
        verify(mockUidGenerator.generateUid).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthState.loading, AuthState.unauthenticated] '
      'when watch user stream emits failure',
      setUp: () {
        when(
          () => mockWatchUser.execute(traceId: traceId),
        ).thenAnswer(
          (_) => Stream.value(
            AppResult<User?>.failure(AppException.test()),
          ),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const AuthEvent.subscriptionRequested()),
      expect: () => const <AuthState>[
        AuthState.loading(),
        AuthState.unauthenticated(),
      ],
      verify: (_) {
        verify(
          () => mockWatchUser.execute(traceId: traceId),
        ).called(1);
        verify(mockUidGenerator.generateUid).called(1);
      },
    );
  });
}
