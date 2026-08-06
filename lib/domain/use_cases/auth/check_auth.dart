import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';

/// Use case to check current authentication state
@lazySingleton
class CheckAuthUseCase implements FutureBaseUseCase<NoParams, bool> {
  /// Creates new [CheckAuthUseCase]
  CheckAuthUseCase({required this._authRepository})
    : _logger = AppLogger('CheckAuthUseCase');

  final IAuthRepository _authRepository;
  final AppLogger _logger;

  @override
  Future<AppResult<bool>> execute(
    NoParams params, {
    required String traceId,
  }) async {
    _logger.info('Start checks auth state', traceId: traceId);
    final result = await _authRepository.getCurrentUserId(traceId: traceId);
    _logger.info('Finished checks auth state', traceId: traceId);
    return result.when(
      success: (_) => const AppResult.success(true),
      failure: (exc) {
        if (exc.code == AppExceptionCode.unauthenticated) {
          return const AppResult.success(false);
        }
        return AppResult.failure(exc);
      },
    );
  }
}
