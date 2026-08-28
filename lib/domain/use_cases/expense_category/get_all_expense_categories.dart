import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/entities/expense_category.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/repositories/i_expense_category.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';

part 'get_all_expense_categories.freezed.dart';

/// Params for [GetAllExpenseCategoriesUseCase]
@freezed
sealed class GetAllExpenseCategoriesParams
    with _$GetAllExpenseCategoriesParams {
  const factory GetAllExpenseCategoriesParams({
    String? query,
  }) = _GetAllExpenseCategoriesParams;
}

/// Use case to get all expense categories saved on
/// current user database
@lazySingleton
class GetAllExpenseCategoriesUseCase
    with Loggable
    implements
        FutureBaseUseCase<
          GetAllExpenseCategoriesParams,
          List<ExpenseCategory>
        > {
  /// Creates new [GetAllExpenseCategoriesUseCase]
  GetAllExpenseCategoriesUseCase({
    required this._authRepository,
    required this._expenseCategoryRepository,
  });

  @override
  String get logTag => 'GetAllExpenseCategoriesUseCase';

  final IAuthRepository _authRepository;
  final IExpenseCategoryRepository _expenseCategoryRepository;

  /// Execute getting all expense categories from current user
  @override
  Future<AppResult<List<ExpenseCategory>>> execute(
    GetAllExpenseCategoriesParams params, {
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
      'Got current user id. Starts getting expense categories',
      traceId: traceId,
    );
    final accountsResult = await _expenseCategoryRepository.getAll(
      userId: userId,
      query: params.query,
      traceId: traceId,
      isDeleted: false,
    );
    final accountsExc = accountsResult.errorOrNull;
    if (accountsExc != null) {
      logInfo('Failed to get expense categories', traceId: traceId);
      return AppResult.failure(accountsExc);
    }

    final accounts = accountsResult.valueOrNull!;
    logInfo(
      'Got ${accounts.length} expense categories',
      traceId: traceId,
    );
    return AppResult.success(accounts);
  }
}
