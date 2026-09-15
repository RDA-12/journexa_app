import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/use_cases/auth/login_with_google.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';
import 'package:journexa_app/ui/login/bloc/login_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginWithGoogleUseCase extends Mock implements LoginWithGoogleUseCase;

class MockUidGenerator extends Mock implements UidGenerator;

void main() {
  late MockLoginWithGoogleUseCase mockLoginWithGoogleUseCase;
  late MockUidGenerator mockUidGenerator;

  const traceId = 'test-trace-id';

  setUp(() {
    mockLoginWithGoogleUseCase = MockLoginWithGoogleUseCase();
    mockUidGenerator = MockUidGenerator();
    when(() => mockUidGenerator.generateUid()).thenReturn(traceId);
    when(
      () => mockLoginWithGoogleUseCase.execute(
        traceId: traceId,
      ),
    ).thenAnswer((_) async => const AppResult<void>.success(null));
  });

  LoginBloc buildBloc() {
    return LoginBloc(
      loginWithGoogleUseCase: mockLoginWithGoogleUseCase,
    )..customGenerator = mockUidGenerator;
  }

  test('initial state is LoginState.initial()', () {
    expect(buildBloc().state, equals(const LoginState.initial()));
  });

  group('LoginEvent.loginWithGoogle', () {
    blocTest<LoginBloc, LoginState>(
      'emits [LoginState.loading(), LoginState.success()] when login succeeds',
      build: buildBloc,
      act: (bloc) => bloc.add(const LoginEvent.loginWithGoogle()),
      expect: () => const <LoginState>[
        LoginState.loading(),
        LoginState.success(),
      ],
      verify: (_) {
        verify(() => mockUidGenerator.generateUid()).called(1);
        verify(
          () => mockLoginWithGoogleUseCase.execute(
            traceId: traceId,
          ),
        ).called(1);
      },
    );

    blocTest<LoginBloc, LoginState>(
      'emits [LoginState.loading(), LoginState.failure()] when login fails',
      setUp: () {
        const exception = AppException(
          'User canceled login',
          code: AppExceptionCode.loginCanceled,
        );
        when(
          () => mockLoginWithGoogleUseCase.execute(
            traceId: traceId,
          ),
        ).thenAnswer(
          (_) async => const AppResult<void>.failure(exception),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const LoginEvent.loginWithGoogle()),
      expect: () => const <LoginState>[
        LoginState.loading(),
        LoginState.failure(
          AppException(
            'User canceled login',
            code: AppExceptionCode.loginCanceled,
          ),
        ),
      ],
      verify: (_) {
        verify(() => mockUidGenerator.generateUid()).called(1);
        verify(
          () => mockLoginWithGoogleUseCase.execute(
            traceId: traceId,
          ),
        ).called(1);
      },
    );
  });
}
