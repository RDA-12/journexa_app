import 'package:journexa_app/domain/entities/expense_category.dart';
import 'package:journexa_app/shared/app_result.dart';

/// Repository to handles operations for [ExpenseCategory]
abstract interface class IExpenseCategoryRepository {
  /// Save [category] in database
  Future<AppResult<Null>> save({
    required ExpenseCategory category,
    required String traceId,
  });

  /// Watch all [ExpenseCategory] from database
  Stream<AppResult<List<ExpenseCategory>>> watch({
    required String traceId,
    String? query,
    bool? isDeleted,
  });

  /// Delete [category] from database
  Future<AppResult<Null>> delete({
    required ExpenseCategory category,
    required String traceId,
  });

  /// Update [updatedCategory] in database
  Future<AppResult<Null>> update({
    required ExpenseCategory updatedCategory,
    required String traceId,
  });
}
