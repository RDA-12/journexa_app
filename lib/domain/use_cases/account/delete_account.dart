import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/repositories/i_account_repository.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';

part 'delete_account.freezed.dart';

/// Params for [DeleteAccountUseCase]
@freezed
sealed class DeleteAccountParams with _$DeleteAccountParams {
  /// Creates new [DeleteAccountParams]
  const factory DeleteAccountParams({
    /// [Account] that will be deleted
    required Account account,
  }) = _DeleteAccountsParams;
}

/// Use Case to delete a cash account in current user database
@lazySingleton
class DeleteAccountUseCase
    with Loggable
    implements FutureBaseUseCase<DeleteAccountParams, Null> {
  /// Creates new [DeleteAccountUseCase]
  DeleteAccountUseCase({
    required this._authRepository,
    required this._accountRepository,
  });

  @override
  String get logTag => 'DeleteAccountUseCase';

  final IAuthRepository _authRepository;
  final IAccountRepository _accountRepository;

  /// Execute deletting account in [params] for current user
  @override
  Future<AppResult<Null>> execute(
    DeleteAccountParams params, {
    required String traceId,
  }) async {
    logInfo('Starts getting current user id', traceId: traceId);
    final userIdResult = await _authRepository.getCurrentUserId(
      traceId: traceId,
    );
    final userIdExc = userIdResult.errorOrNull;
    if (userIdExc != null) {
      logInfo('Failed to get current user id', traceId: traceId);
      return AppResult.failure(userIdExc);
    }

    logInfo(
      'User id obtained. Start delete account with code ${params.account.code}',
      traceId: traceId,
    );
    final userId = userIdResult.valueOrNull!;
    final deleteResult = await _accountRepository.deleteByCode(
      userId: userId,
      code: params.account.code,
      traceId: traceId,
    );
    final deleteExc = deleteResult.errorOrNull;
    if (deleteExc != null) {
      logInfo('Failed to delete account', traceId: traceId);
      return AppResult.failure(deleteExc);
    }

    logInfo('Account deleted successfully', traceId: traceId);
    return const AppResult.success(null);
  }
}
