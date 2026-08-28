import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/repositories/i_income_category.dart';
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
    implements
        FutureBaseUseCase<GetAllIncomeCategoriesParams, List<IncomeCategory>> {
  /// Creates new [GetAllIncomeCategoriesUseCase]
  GetAllIncomeCategoriesUseCase({
    required this._incomeCategoryRepository,
    required this._authRepository,
  });

  @override
  String get logTag => 'GetAllIncomeCategoriesUseCase';

  final IAuthRepository _authRepository;
  final IIncomeCategoryRepository _incomeCategoryRepository;

  /// Execute getting all income categories from current user
  @override
  Future<AppResult<List<IncomeCategory>>> execute(
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
    final accountsResult = await _incomeCategoryRepository.getAll(
      userId: userId,
      query: params.query,
      isDeleted: false,
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
