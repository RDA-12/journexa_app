import 'package:journexa_app/domain/entities/expense_category.dart';
import 'package:journexa_app/shared/app_result.dart';

/// Repository to handles operations for [ExpenseCategory]
abstract interface class IExpenseCategoryRepository {
  /// Save [category] in [userId] database
  Future<AppResult<Null>> save({
    required String userId,
    required ExpenseCategory category,
    required String traceId,
  });

  /// Watch all [ExpenseCategory] from [userId] database
  Stream<AppResult<List<ExpenseCategory>>> watch({
    required String userId,
    required String traceId,
    String? query,
    bool? isDeleted,
  });

  /// Delete [category] from [userId] database
  Future<AppResult<Null>> delete({
    required String userId,
    required ExpenseCategory category,
    required String traceId,
  });

  /// Update [updatedCategory] in [userId] database
  Future<AppResult<Null>> update({
    required String userId,
    required ExpenseCategory updatedCategory,
    required String traceId,
  });
}
