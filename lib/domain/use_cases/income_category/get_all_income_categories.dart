import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/repositories/i_account_repository.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';

part 'get_all_income_categories.freezed.dart';

/// Params for [GetAllIncomeCategoriesUseCase]
@freezed
sealed class GetAllIncomeCategoriesParams with _$GetAllIncomeCategoriesParams {
  const factory GetAllIncomeCategoriesParams({
    String? query,
  }) = _GetAllIncomeCategoriesParams;
}

/// Use case to get all income categories saved on
/// current user database
@lazySingleton
class GetAllIncomeCategoriesUseCase
    with Loggable
    implements FutureBaseUseCase<GetAllIncomeCategoriesParams, List<Account>> {
  /// Creates new [GetAllIncomeCategoriesUseCase]
  GetAllIncomeCategoriesUseCase({
    required this._accountRepository,
    required this._authRepository,
  });

  @override
  String get logTag => 'GetAllIncomeCategoriesUseCase';

  final IAuthRepository _authRepository;
  final IAccountRepository _accountRepository;

  /// Execute getting all income categories from current user
  @override
  Future<AppResult<List<Account>>> execute(
    GetAllIncomeCategoriesParams params, {
    required String traceId,
  }) async {
    logInfo('Starts getting current user id ', traceId: traceId);
    final currentUserIdResult = await _authRepository.getCurrentUserId(
      traceId: traceId,
    );
    final currentUserIdExc = currentUserIdResult.errorOrNull;
    if (currentUserIdExc != null) {
      logInfo('Failed to get current user id', traceId: traceId);
      return AppResult.failure(currentUserIdExc);
    }

    final userId = currentUserIdResult.valueOrNull!;
    logInfo(
      'Got current user id. Starts getting income categories',
      traceId: traceId,
    );
    const parentCode = '40.0000';
    final accountsResult = await _accountRepository.getByParentCode(
      userId: userId,
      parentCode: parentCode,
      query: params.query,
      traceId: traceId,
    );
    final accountsExc = accountsResult.errorOrNull;
    if (accountsExc != null) {
      logInfo('Failed to get income categories', traceId: traceId);
      return AppResult.failure(accountsExc);
    }

    final accounts = accountsResult.valueOrNull!;
    logInfo(
      'Got ${accounts.length} income categories',
      traceId: traceId,
    );
    return AppResult.success(accounts);
  }
}
