import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';

@lazySingleton
/// Use case for logging in user with google
class LoginWithGoogleUseCase
    with Loggable
    implements FutureBaseUseCase<NoParams, void> {
  /// Creates new [LoginWithGoogleUseCase]
  LoginWithGoogleUseCase(this._authRepository);

  @override
  String get logTag => 'LoginWithGoogleUseCase';

  final IAuthRepository _authRepository;

  /// Executes logging in user with google
  @override
  Future<AppResult<void>> execute(
    NoParams params, {
    required String traceId,
  }) async {
    logInfo('Starts login with google', traceId: traceId);
    final result = await _authRepository.loginWithGoogle(traceId: traceId);
    result.when(
      success: (_) {
        logInfo('Finished login with google', traceId: traceId);
      },
      failure: (failure) {
        logError(
          'Failed to login with google: ${failure.message}',
          traceId: traceId,
        );
      },
    );
    return result;
  }
}
