import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';

/// Firebase implementation of [IAuthRepository]
@LazySingleton(as: IAuthRepository)
class FirebaseAuthRepository with Loggable implements IAuthRepository {
  /// Creates new [FirebaseAuthRepository]
  FirebaseAuthRepository({required this._auth, required this._googleSignIn});

  @override
  String get logTag => 'FirebaseAuthRepository';

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  @override
  Future<AppResult<void>> loginWithGoogle({required String traceId}) async {
    try {
      logInfo('Trigger Google auth flow', traceId: traceId);
      final googleUser = await _googleSignIn.authenticate();

      logInfo(
        'Auth flow success. Obtain auth details',
        traceId: traceId,
      );
      final googleAuth = googleUser.authentication;

      logInfo(
        'Auth detail obtained. '
        'Creates credential for Firebase Auth',
        traceId: traceId,
      );

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      logInfo(
        'Credential created. '
        'Logging in to Firebase Auth with credentials',
        traceId: traceId,
      );
      await _auth.signInWithCredential(credential);
      logInfo('User logged in', traceId: traceId);

      return const AppResult.success(null);
    } on GoogleSignInException catch (e, st) {
      final code = e.code;
      if (code == GoogleSignInExceptionCode.canceled) {
        logInfo(
          'Google log in canceled by user',
          traceId: traceId,
        );
        return const AppResult.failure(
          AppException(
            'Google log in canceled by user',
            code: AppExceptionCode.loginCanceled,
          ),
        );
      }
      logError(
        'Google log in flow fail: ${e.description ?? code}',
        error: e,
        stackTrace: st,
        traceId: traceId,
      );
      return AppResult.failure(
        AppException(
          e.description ?? code.name,
          code: AppExceptionCode.internalException,
        ),
      );
    } on FirebaseException catch (e) {
      logError(
        e.toString(),
        error: e,
        traceId: traceId,
      );
      return AppResult.failure(
        AppException(e.toString(), code: AppExceptionCode.serverException),
      );
    } on Exception catch (e, st) {
      logError(
        'Unexpected failure: $e',
        error: e,
        stackTrace: st,
        traceId: traceId,
      );
      return AppResult.failure(
        AppException(
          e.toString(),
          code: AppExceptionCode.internalException,
        ),
      );
    }
  }

  @override
  Future<AppResult<String>> getCurrentUserId({required String traceId}) async {
    logInfo('Get current user id', traceId: traceId);
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return const AppResult.failure(
        AppException(
          'userId is null. probably user is not logged in',
          code: AppExceptionCode.unauthenticated,
        ),
      );
    }
    logInfo(
      'User id found.',
      traceId: traceId,
    );
    return AppResult.success(userId);
  }
}
