import 'package:journexa_app/shared/app_result.dart';

/// Repository that handles authentication operations
abstract interface class IAuthRepository {
  /// Logging in user with their google account
  Future<AppResult<void>> loginWithGoogle({required String traceId});

  /// Returns current user id
  Future<AppResult<String>> getCurrentUserId({required String traceId});
}
