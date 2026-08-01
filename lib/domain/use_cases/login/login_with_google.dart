import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';

@lazySingleton
/// Use case for logging in user with google
class LoginWithGoogleUseCase implements FutureBaseUseCase<NoParams, void> {
  /// Creates new [LoginWithGoogleUseCase]
  LoginWithGoogleUseCase(this._authRepository)
    : _logger = AppLogger('LoginWithGoogleUseCase');

  final IAuthRepository _authRepository;
  final AppLogger _logger;

  /// Executes logging in user with google
  @override
  Future<AppResult<void>> execute(
    NoParams params, {
    required String traceId,
  }) async {
    _logger.info('Starts login with google', traceId: traceId);
    final result = await _authRepository.loginWithGoogle(traceId: traceId);
    result.when(
      success: (_) {
        _logger.info('Finished login with google', traceId: traceId);
      },
      failure: (failure) {
        _logger.error(
          'Failed to login with google: ${failure.message}',
          traceId: traceId,
        );
      },
    );
    return result;
  }
}
