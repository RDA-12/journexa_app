import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:journexa_app/data/repositories/auth_repository.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

class MockUserCredential extends Mock implements UserCredential {}

class FakeAuthCredential extends Fake implements AuthCredential {}

void main() {
  late MockFirebaseAuth mockAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockGoogleSignInAccount mockGoogleUser;
  late MockGoogleSignInAuthentication mockGoogleAuth;
  late MockUserCredential mockUserCredential;
  late FirebaseAuthRepository repository;

  const traceId = 'test-trace-id';

  setUpAll(() {
    registerFallbackValue(FakeAuthCredential());
  });

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    mockGoogleUser = MockGoogleSignInAccount();
    mockGoogleAuth = MockGoogleSignInAuthentication();
    mockUserCredential = MockUserCredential();

    repository = FirebaseAuthRepository(
      auth: mockAuth,
      googleSignIn: mockGoogleSignIn,
    );
  });

  group('loginWithGoogle', () {
    test(
      'succeeds when Google sign-in and Firebase authentication succeed',
      () async {
        when(
          () => mockGoogleSignIn.authenticate(),
        ).thenAnswer((_) async => mockGoogleUser);
        when(
          () => mockGoogleUser.authentication,
        ).thenReturn(mockGoogleAuth);
        when(() => mockGoogleAuth.idToken).thenReturn('mock-id-token');
        when(
          () => mockAuth.signInWithCredential(any()),
        ).thenAnswer((_) async => mockUserCredential);

        final result = await repository.loginWithGoogle(traceId: traceId);

        expect(result, equals(const AppResult<void>.success(null)));
        verify(() => mockGoogleSignIn.authenticate()).called(1);
        verify(() => mockAuth.signInWithCredential(any())).called(1);
      },
    );

    test(
      'returns AppException with loginCanceled code when Google sign-in is '
      'canceled by user and ensures remaining action is not called',
      () async {
        when(() => mockGoogleSignIn.authenticate()).thenThrow(
          const GoogleSignInException(
            code: GoogleSignInExceptionCode.canceled,
            description: 'Google log in canceled by user',
          ),
        );

        final result = await repository.loginWithGoogle(traceId: traceId);

        expect(
          result,
          equals(
            const AppResult<void>.failure(
              AppException(
                'Google log in canceled by user',
                code: AppExceptionCode.loginCanceled,
              ),
            ),
          ),
        );

        verify(() => mockGoogleSignIn.authenticate()).called(1);
        verifyNever(() => mockAuth.signInWithCredential(any()));
      },
    );

    test(
      'returns AppException with internalException code when Google sign-in '
      'fails with non-cancel error and ensures remaining action is not called',
      () async {
        final nonCancelCode = GoogleSignInExceptionCode.values.firstWhere(
          (code) => code != GoogleSignInExceptionCode.canceled,
        );

        when(() => mockGoogleSignIn.authenticate()).thenThrow(
          GoogleSignInException(
            code: nonCancelCode,
            description: 'Google sign-in failed',
          ),
        );

        final result = await repository.loginWithGoogle(traceId: traceId);

        expect(
          result,
          equals(
            const AppResult<void>.failure(
              AppException(
                'Google sign-in failed',
                code: AppExceptionCode.internalException,
              ),
            ),
          ),
        );

        verify(() => mockGoogleSignIn.authenticate()).called(1);
        verifyNever(() => mockAuth.signInWithCredential(any()));
      },
    );

    test(
      'returns AppException with internalException code when Google sign-in '
      'throws generic Exception and ensures remaining action is not called',
      () async {
        final exception = Exception('Network error');
        when(() => mockGoogleSignIn.authenticate()).thenThrow(exception);

        final result = await repository.loginWithGoogle(traceId: traceId);

        expect(
          result,
          equals(
            const AppResult<void>.failure(
              AppException(
                'Exception: Network error',
                code: AppExceptionCode.internalException,
              ),
            ),
          ),
        );

        verify(() => mockGoogleSignIn.authenticate()).called(1);
        verifyNever(() => mockAuth.signInWithCredential(any()));
      },
    );

    test(
      'returns AppException with internalException code when Firebase '
      'signInWithCredential throws Exception',
      () async {
        when(
          () => mockGoogleSignIn.authenticate(),
        ).thenAnswer((_) async => mockGoogleUser);
        when(
          () => mockGoogleUser.authentication,
        ).thenReturn(mockGoogleAuth);
        when(() => mockGoogleAuth.idToken).thenReturn('mock-id-token');

        final firebaseException = Exception('Firebase authentication failed');
        when(
          () => mockAuth.signInWithCredential(any()),
        ).thenThrow(firebaseException);

        final result = await repository.loginWithGoogle(traceId: traceId);

        expect(
          result,
          equals(
            const AppResult<void>.failure(
              AppException(
                'Exception: Firebase authentication failed',
                code: AppExceptionCode.internalException,
              ),
            ),
          ),
        );

        verify(() => mockGoogleSignIn.authenticate()).called(1);
        verify(() => mockAuth.signInWithCredential(any())).called(1);
      },
    );
  });
}
