import 'package:journexa_app/domain/entities/user.dart';
import 'package:journexa_app/shared/app_result.dart';

/// Repository that handles authentication operations
abstract interface class IAuthRepository {
  /// Logging in user with their google account
  Future<AppResult<void>> loginWithGoogle({required String traceId});

  /// Returns streams of User
  ///
  /// When it emits null, it means the user has been logged out
  Stream<AppResult<User?>> watchUser({required String traceId});
}
