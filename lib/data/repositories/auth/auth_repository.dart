import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/entities/user.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:rxdart/rxdart.dart';

/// Firebase implementation of [IAuthRepository]
@LazySingleton(as: IAuthRepository)
class FirebaseAuthRepository with Loggable implements IAuthRepository {
  /// Creates new [FirebaseAuthRepository]
  new({required this._auth, required this._googleSignIn});

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
  Stream<AppResult<User?>> watchUser({required String traceId}) {
    logInfo('Starts watching user changes', traceId: traceId);
    return _auth
        .userChanges()
        .map<AppResult<User?>>((firebaseUser) {
          if (firebaseUser == null) {
            return const AppResult.success(null);
          }
          return AppResult.success(
            User(
              id: firebaseUser.uid,
              name: firebaseUser.displayName ?? 'User-${firebaseUser.uid}',
              email: firebaseUser.email,
              photoUrl: firebaseUser.photoURL,
            ),
          );
        })
        .onErrorReturnWith((error, st) {
          logError('$error', traceId: traceId, error: error, stackTrace: st);
          return AppResult.failure(
            AppException('$error', code: AppExceptionCode.internalException),
          );
        });
  }
}
