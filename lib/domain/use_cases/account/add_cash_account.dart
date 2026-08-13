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
    implements FutureBaseUseCase<AddCashAccountParams, Null> {
  /// Creates new [AddCashAccountUseCase]
  AddCashAccountUseCase({
    required this._accountRepository,
    required this._authRepository,
  }) : _logger = AppLogger('AddCashAccountUseCase');

  final IAuthRepository _authRepository;
  final IAccountRepository _accountRepository;
  final AppLogger _logger;

  /// Starts executing [AddCashAccountUseCase]
  @override
  Future<AppResult<Null>> execute(
    AddCashAccountParams params, {
    required String traceId,
  }) async {
    _logger.info(
      'Start adding new cash Account. Get current user id',
      traceId: traceId,
      extras: params.extras,
    );
    final getCurrentUserIdResult = await _authRepository.getCurrentUserId(
      traceId: traceId,
    );
    final getCurrentUserIdExc = getCurrentUserIdResult.errorOrNull;
    if (getCurrentUserIdExc != null) {
      _logger.info(
        'Failed to get current user id.',
        traceId: traceId,
      );
      return AppResult.failure(getCurrentUserIdExc);
    }
    _logger.info('userId obtained', traceId: traceId);
    final userId = getCurrentUserIdResult.valueOrNull!;

    _logger.info('Get parent Account for asset', traceId: traceId);
    final parentAssetAccount = kSystemDefinedAccounts.firstWhere(
      (it) => it.code == '10.0000',
    );
    _logger.info(
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
      _logger.info(
        'Failed to get children count for asset parent Account.',
        traceId: traceId,
      );
      return AppResult.failure(getChildrenCountExc);
    }
    final childrenCount = getChildrenCountResult.valueOrNull!;
    _logger.info(
      'children count obtained. Creating new Account object',
      traceId: traceId,
    );

    final newAccount = Account.user(
      parent: parentAssetAccount,
      name: params.name,
      currentChildrenCount: childrenCount,
    );
    _logger.info('New Account created. Saving Account', traceId: traceId);

    final saveResult = await _accountRepository.save(
      userId,
      newAccount,
      traceId: traceId,
    );
    return saveResult.when(
      success: (_) {
        _logger.info('new Account saved successfully. Done.', traceId: traceId);
        return const AppResult<Null>.success(null);
      },
      failure: (exc) {
        _logger.info('Failed to save new Account', traceId: traceId);
        return AppResult.failure(exc);
      },
    );
  }
}
