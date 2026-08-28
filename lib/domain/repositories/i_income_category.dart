import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/shared/app_result.dart';

/// Repository to handles operations for [IncomeCategory]
abstract interface class IIncomeCategoryRepository {
  /// Save [category] in [userId] database
  Future<AppResult<Null>> save({
    required String userId,
    required IncomeCategory category,
    required String traceId,
  });

  /// Get all [IncomeCategory] from [userId] database
  Future<AppResult<List<IncomeCategory>>> getAll({
    required String userId,
    required String traceId,
    String? query,
    bool? isDeleted,
  });

  /// Delete [category] from [userId] database
  Future<AppResult<Null>> delete({
    required String userId,
    required IncomeCategory category,
    required String traceId,
  });

  /// Update [updatedCategory] in [userId] database
  Future<AppResult<Null>> update({
    required String userId,
    required IncomeCategory updatedCategory,
    required String traceId,
  });
}
