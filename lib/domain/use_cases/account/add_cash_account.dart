import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/repositories/i_account_repository.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';

part 'add_cash_account.freezed.dart';

/// Params for [AddCashAccountUseCase]
@freezed
sealed class AddCashAccountParams with _$AddCashAccountParams {
  const factory AddCashAccountParams({
    /// Name for new [Account]
    required String name,
  }) = _AddCashAccountParams;
  const AddCashAccountParams._();

  /// Returns extra data for logging
  Map<String, Object?> get extras {
    return {
      'name': name,
    };
  }
}

/// Use case for adding new [Account] to current user database.
@lazySingleton
class AddCashAccountUseCase
    with Loggable
    implements FutureBaseUseCase<AddCashAccountParams, Null> {
  /// Creates new [AddCashAccountUseCase]
  AddCashAccountUseCase({
    required this._accountRepository,
    required this._authRepository,
  });

  @override
  String get logTag => 'AddCashAccountUseCase';

  final IAuthRepository _authRepository;
  final IAccountRepository _accountRepository;

  /// Starts executing [AddCashAccountUseCase]
  @override
  Future<AppResult<Null>> execute(
    AddCashAccountParams params, {
    required String traceId,
  }) async {
    logInfo(
      'Start adding new cash Account. Get current user id',
      traceId: traceId,
      extras: params.extras,
    );
    final getCurrentUserIdResult = await _authRepository.getCurrentUserId(
      traceId: traceId,
    );
    final getCurrentUserIdExc = getCurrentUserIdResult.errorOrNull;
    if (getCurrentUserIdExc != null) {
      logInfo(
        'Failed to get current user id.',
        traceId: traceId,
      );
      return AppResult.failure(getCurrentUserIdExc);
    }
    logInfo('userId obtained', traceId: traceId);
    final userId = getCurrentUserIdResult.valueOrNull!;

    logInfo('Get parent Account for asset', traceId: traceId);
    final parentAssetAccount = kSystemDefinedAccounts.firstWhere(
      (it) => it.code == '10.0000',
    );
    logInfo(
      'Asset parent Account obtained. Get children count',
      traceId: traceId,
    );

    final getChildrenCountResult = await _accountRepository
        .getChildrenCountByParentCode(
          userId: userId,
          parentCode: parentAssetAccount.code,
          traceId: traceId,
        );
    final getChildrenCountExc = getChildrenCountResult.errorOrNull;
    if (getChildrenCountExc != null) {
      logInfo(
        'Failed to get children count for asset parent Account.',
        traceId: traceId,
      );
      return AppResult.failure(getChildrenCountExc);
    }
    final childrenCount = getChildrenCountResult.valueOrNull!;
    logInfo(
      'children count obtained. Creating new Account object',
      traceId: traceId,
    );

    final newAccount = Account.user(
      parent: parentAssetAccount,
      name: params.name,
      currentChildrenCount: childrenCount,
    );
    logInfo('New Account created. Saving Account', traceId: traceId);

    final saveResult = await _accountRepository.save(
      userId,
      newAccount,
      traceId: traceId,
    );
    return saveResult.when(
      success: (_) {
        logInfo('new Account saved successfully. Done.', traceId: traceId);
        return const AppResult<Null>.success(null);
      },
      failure: (exc) {
        logInfo('Failed to save new Account', traceId: traceId);
        return AppResult.failure(exc);
      },
    );
  }
}
