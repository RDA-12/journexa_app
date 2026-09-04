import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/entities/expense_category.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/repositories/i_expense_category_repository.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';

part 'update_expense_category.freezed.dart';

/// Params for [UpdateExpenseCategoryUseCase]
@freezed
sealed class UpdateExpenseCategoryParams with _$UpdateExpenseCategoryParams {
  const factory UpdateExpenseCategoryParams({
    /// ExpenseCategory that will be updated
    required ExpenseCategory category,

    /// Optional new name
    String? name,
  }) = _UpdateExpenseCategoryParams;
}

/// Use case to update existing [ExpenseCategory] for current user
@lazySingleton
class UpdateExpenseCategoryUseCase
    with Loggable
    implements FutureBaseUseCase<UpdateExpenseCategoryParams, ExpenseCategory> {
  /// Creates new [UpdateExpenseCategoryUseCase]
  UpdateExpenseCategoryUseCase({
    required this._authRepository,
    required this._expenseCategoryRepository,
  });

  @override
  String get logTag => 'UpdateExpenseCategoryUseCase';

  final IAuthRepository _authRepository;
  final IExpenseCategoryRepository _expenseCategoryRepository;

  /// Execute updating an [ExpenseCategory]
  @override
  Future<AppResult<ExpenseCategory>> execute(
    UpdateExpenseCategoryParams params, {
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
      'User id obtained. Starts updating the ExpenseCategory',
      traceId: traceId,
      extras: {
        'id': params.category.id,
      },
    );
    final userId = userIdResult.valueOrNull!;
    final updatedCategory = params.category.update(
      name: params.name,
    );
    final saveResult = await _expenseCategoryRepository.update(
      userId: userId,
      updatedCategory: updatedCategory,
      traceId: traceId,
    );
    final saveExc = saveResult.errorOrNull;
    if (saveExc != null) {
      logInfo('Failed to save updated category', traceId: traceId);
      return AppResult.failure(saveExc);
    }

    logInfo('Updated category saved. Finishing', traceId: traceId);
    return AppResult.success(updatedCategory);
  }
}
