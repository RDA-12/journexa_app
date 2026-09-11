import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/entities/expense_category.dart';
import 'package:journexa_app/domain/repositories/i_expense_category_repository.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';

part 'delete_expense_category.freezed.dart';

/// Params for [DeleteExpenseCategoryUseCase]
@freezed
sealed class DeleteExpenseCategoryParams with _$DeleteExpenseCategoryParams {
  /// Creates new [DeleteExpenseCategoryParams]
  const factory DeleteExpenseCategoryParams({
    /// [ExpenseCategory] that will be deleted
    required ExpenseCategory category,
  }) = _DeleteExpenseCategoryParams;
}

/// Use Case to delete an expense category in current user database
@lazySingleton
class DeleteExpenseCategoryUseCase
    with Loggable
    implements FutureBaseUseCase<DeleteExpenseCategoryParams, Null> {
  /// Creates new [DeleteExpenseCategoryUseCase]
  DeleteExpenseCategoryUseCase({
    required this._expenseCategoryRepository,
  });

  @override
  String get logTag => 'DeleteExpenseCategoryUseCase';

  final IExpenseCategoryRepository _expenseCategoryRepository;

  /// Execute deletting expense category in [params] for current user
  @override
  Future<AppResult<Null>> execute(
    DeleteExpenseCategoryParams params, {
    required String traceId,
  }) async {
    logInfo('Starts deleting', traceId: traceId);
    final deleteResult = await _expenseCategoryRepository.delete(
      category: params.category,
      traceId: traceId,
    );
    final deleteExc = deleteResult.errorOrNull;
    if (deleteExc != null) {
      logInfo('Failed to delete category', traceId: traceId);
      return AppResult.failure(deleteExc);
    }

    logInfo('ExpenseCategory deleted successfully', traceId: traceId);
    return const AppResult.success(null);
  }
}
