import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/repositories/i_account_repository.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';

part 'update_account.freezed.dart';

/// Params for [UpdateAccountUseCase]
@freezed
sealed class UpdateAccountParams with _$UpdateAccountParams {
  const factory UpdateAccountParams({
    /// Account code that will be updated
    required String code,

    /// Optional new name
    String? name,
  }) = _UpdateAccountParams;
}

/// Use case to update existing [Account] for current user
@lazySingleton
class UpdateAccountUseCase
    with Loggable
    implements FutureBaseUseCase<UpdateAccountParams, Account> {
  /// Creates new [UpdateAccountUseCase]
  UpdateAccountUseCase({
    required this._authRepository,
    required this._accountRepository,
  });

  @override
  String get logTag => 'UpdateAccountUseCase';

  final IAuthRepository _authRepository;
  final IAccountRepository _accountRepository;

  /// Execute updating an [Account]
  @override
  Future<AppResult<Account>> execute(
    UpdateAccountParams params, {
    required String traceId,
  }) async {
    logInfo('Start getting current user id', traceId: traceId);
    final userIdResult = await _authRepository.getCurrentUserId(
      traceId: traceId,
    );
    final userIdExc = userIdResult.errorOrNull;
    if (userIdExc != null) {
      logInfo('Failed to get current user id', traceId: traceId);
      return AppResult.failure(userIdExc);
    }

    logInfo(
      'User id obtained. Starts getting requested account',
      traceId: traceId,
      extras: {
        'code': params.code,
      },
    );
    final userId = userIdResult.valueOrNull!;
    final accountResult = await _accountRepository.getByCode(
      code: params.code,
      userId: userId,
      traceId: traceId,
    );
    final accountExc = accountResult.errorOrNull;
    if (accountExc != null) {
      logInfo('Failed to get requested account', traceId: traceId);
      return AppResult.failure(accountExc);
    }

    logInfo('Requested account obtained. Starts updating', traceId: traceId);
    final account = accountResult.valueOrNull!;
    final updatedAccount = account.update(
      name: params.name,
    );
    final saveResult = await _accountRepository.update(
      userId: userId,
      updatedAccount: updatedAccount,
      traceId: traceId,
    );
    final saveExc = saveResult.errorOrNull;
    if (saveExc != null) {
      logInfo('Failed to save updated account', traceId: traceId);
      return AppResult.failure(saveExc);
    }

    logInfo('Updated account saved. Finishing', traceId: traceId);
    return AppResult.success(updatedAccount);
  }
}
