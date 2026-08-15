import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/repositories/i_account_repository.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';

/// Use case to initialize system [Account]s
///
/// It will seeds default systems account to be used through out
/// the apps.
@lazySingleton
class InitializeAccountsUseCase
    with Loggable
    implements FutureBaseUseCase<NoParams, void> {
  /// Creates new [InitializeAccountsUseCase]
  InitializeAccountsUseCase({
    required this._accountRepository,
    required this._authRepository,
  });

  @override
  String get logTag => 'InitializeAccountsUseCase';

  final IAuthRepository _authRepository;
  final IAccountRepository _accountRepository;

  /// Executes initialization of systems account
  @override
  Future<AppResult<void>> execute(
    NoParams params, {
    required String traceId,
  }) async {
    logInfo('Start getting current user id', traceId: traceId);
    final currentUserIdResult = await _authRepository.getCurrentUserId(
      traceId: traceId,
    );

    final userId = currentUserIdResult.whenOrNull(success: (userId) => userId);
    if (userId == null) {
      logInfo('Get current user id failed', traceId: traceId);
      return currentUserIdResult;
    }

    logInfo(
      'Start ensuring all default system defined accounts saved for $userId',
      traceId: traceId,
    );
    final initializedResult = await _accountRepository.ensureSaved(
      userId,
      accounts: kSystemDefinedAccounts,
      traceId: traceId,
    );
    logInfo(
      'Default system defined accounts ensured saved for $userId',
      traceId: traceId,
    );
    return initializedResult;
  }
}
