import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/entities/user.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';

/// Use case to watch for user changes
@lazySingleton
class WatchUserUseCase
    with Loggable
    implements StreamBaseUseCaseNoParams<User?> {
  /// Creates new [WatchUserUseCase]
  new({required this._authRepository});

  final IAuthRepository _authRepository;

  @override
  String get logTag => 'WatchUserUseCase';

  @override
  Stream<AppResult<User?>> execute({required String traceId}) {
    logInfo('Starts watching for user changes', traceId: traceId);
    return _authRepository.watchUser(traceId: traceId);
  }
}
