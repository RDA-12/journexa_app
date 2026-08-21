import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/repositories/i_account_repository.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';

part 'add_income_category.freezed.dart';

/// Params for [AddIncomeCategoryUseCase]
@freezed
sealed class AddIncomeCategoryParams with _$AddIncomeCategoryParams {
  const factory AddIncomeCategoryParams({
    /// Name of the category
    required String name,
  }) = _AddIncomeCategoryParams;
  const AddIncomeCategoryParams._();

  /// Return extras of this params meant to be used in logger
  Map<String, String> get extras => {'name': name};
}

/// Use case to creates new income category
@lazySingleton
class AddIncomeCategoryUseCase
    with Loggable
    implements FutureBaseUseCase<AddIncomeCategoryParams, Null> {
  /// Creates new [AddIncomeCategoryUseCase]
  AddIncomeCategoryUseCase({
    required this._authRepository,
    required this._accountRepository,
  });

  final IAuthRepository _authRepository;
  final IAccountRepository _accountRepository;

  @override
  String get logTag => 'AddIncomeCategoryUseCase';

  @override
  Future<AppResult<Null>> execute(
    AddIncomeCategoryParams params, {
    required String traceId,
  }) async {
    logInfo(
      'Start adding new income category. Get current user id',
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
    logInfo('Get parent Account for revenue', traceId: traceId);
    final parentAssetAccount = kSystemDefinedAccounts.firstWhere(
      (it) => it.code == '40.0000',
    );
    logInfo(
      'Revenue parent Account obtained. Get children count',
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
        'Failed to get children count for revenue parent Account.',
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
