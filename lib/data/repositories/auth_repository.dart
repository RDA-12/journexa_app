import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';

/// Firebase implementation of [IAuthRepository]
@LazySingleton(as: IAuthRepository)
class FirebaseAuthRepository implements IAuthRepository {
  /// Creates new [FirebaseAuthRepository]
  FirebaseAuthRepository({required this._auth, required this._googleSignIn})
    : _logger = AppLogger('FirebaseAuthRepository');

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final AppLogger _logger;

  @override
  Future<AppResult<void>> loginWithGoogle({required String traceId}) async {
    try {
      _logger.info('Trigger Google auth flow', traceId: traceId);
      final googleUser = await _googleSignIn.authenticate();

      _logger.info(
        'Auth flow success. Obtain auth details',
        traceId: traceId,
      );
      final googleAuth = googleUser.authentication;

      _logger.info(
        'Auth detail obtained. '
        'Creates credential for Firebase Auth',
        traceId: traceId,
      );

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      _logger.info(
        'Credential created. '
        'Logging in to Firebase Auth with credentials',
        traceId: traceId,
      );
      await _auth.signInWithCredential(credential);
      _logger.info('User logged in', traceId: traceId);

      return const AppResult.success(null);
    } on GoogleSignInException catch (e, st) {
      final code = e.code;
      if (code == GoogleSignInExceptionCode.canceled) {
        _logger.info(
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
      _logger.error(
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
    } on Exception catch (e, st) {
      _logger.error(
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
}
