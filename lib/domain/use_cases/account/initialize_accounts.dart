import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/repositories/i_account_repository.dart';
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
    implements FutureBaseUseCaseNoParams<void> {
  /// Creates new [InitializeAccountsUseCase]
  new({
    required this._accountRepository,
  });

  @override
  String get logTag => 'InitializeAccountsUseCase';

  final IAccountRepository _accountRepository;

  /// Executes initialization of systems account
  @override
  Future<AppResult<void>> execute({
    required String traceId,
  }) async {
    logInfo(
      'Start ensuring all default system defined accounts saved',
      traceId: traceId,
    );
    final initializedResult = await _accountRepository.ensureSaved(
      accounts: SystemDefinedAccount.accounts,
      traceId: traceId,
    );
    logInfo(
      'Default system defined accounts ensured saved',
      traceId: traceId,
    );
    return initializedResult;
  }
}
