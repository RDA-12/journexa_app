import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:journexa_app/data/repositories/auth_repository.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

void main() {
  const traceId = 'test-trace-id';

  late MockFirebaseAuth mockAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late FirebaseAuthRepository repository;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    repository = FirebaseAuthRepository(
      auth: mockAuth,
      googleSignIn: mockGoogleSignIn,
    );
  });

  group('loginWithGoogle', () {
    test(
      'succeeds when Google sign-in and Firebase authentication succeed',
      () async {
        GoogleSignInAccount? user;
        final subscription = mockGoogleSignIn.authenticationEvents.listen((
          data,
        ) {
          user = (data as GoogleSignInAuthenticationEventSignIn).user;
        });

        final result = await repository.loginWithGoogle(traceId: traceId);

        expect(result, equals(const AppResult<void>.success(null)));
        expect(user, isNotNull);
        expect(mockAuth.currentUser, isNotNull);
        await subscription.cancel();
      },
    );

    test(
      'returns AppException with loginCanceled code '
      'when Google sign-in is canceled by user '
      'and ensure the FirebaseAuth not authenticated',
      () async {
        mockGoogleSignIn.setIsCancelled(true);

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
        expect(mockAuth.currentUser, isNull);
      },
    );

    test(
      'returns AppException with internalException code '
      'when Google sign-in fails with non-cancel error '
      'and FirebaseAuth is not authenticated',
      () async {
        mockGoogleSignIn.setException(
          const GoogleSignInException(
            code: GoogleSignInExceptionCode.clientConfigurationError,
          ),
        );

        final result = await repository.loginWithGoogle(traceId: traceId);

        expect(
          result,
          isA<AppResultFailure<void>>().having(
            (e) => e.error.code,
            'error.code',
            AppExceptionCode.internalException,
          ),
        );
        expect(mockAuth.currentUser, isNull);
      },
    );

    test(
      'returns AppException with serverException code '
      'when Firebase signInWithCredential throws FirebaseException',
      () async {
        whenCalling(
          Invocation.method(#signInWithCredential, null),
        ).on(mockAuth).thenThrow(FirebaseException(plugin: 'auth'));

        final result = await repository.loginWithGoogle(traceId: traceId);

        expect(
          result,
          isA<AppResultFailure<void>>().having(
            (e) => e.error.code,
            'code',
            AppExceptionCode.serverException,
          ),
        );
      },
    );

    test(
      'returns AppException with internalException code '
      'when unexpected Exception thrown',
      () async {
        whenCalling(
          Invocation.method(#signInWithCredential, null),
        ).on(mockAuth).thenThrow(Exception('exception'));

        final result = await repository.loginWithGoogle(traceId: traceId);

        expect(
          result,
          isA<AppResultFailure<void>>().having(
            (e) => e.error.code,
            'code',
            AppExceptionCode.internalException,
          ),
        );
      },
    );
  });
}
