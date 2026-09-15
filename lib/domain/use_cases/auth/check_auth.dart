import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';

/// Use case to check current authentication state
@lazySingleton
class CheckAuthUseCase
    with Loggable
    implements FutureBaseUseCaseNoParams<bool> {
  /// Creates new [CheckAuthUseCase]
  new({required this._authRepository});

  @override
  String get logTag => 'CheckAuthUseCase';

  final IAuthRepository _authRepository;

  @override
  Future<AppResult<bool>> execute({
    required String traceId,
  }) async {
    logInfo('Start checks auth state', traceId: traceId);
    final result = await _authRepository.getCurrentUserId(traceId: traceId);
    logInfo('Finished checks auth state', traceId: traceId);
    return await result.when(
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
