import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/shared/app_result.dart';

/// Repository to handles operations for [IncomeCategory]
abstract interface class IIncomeCategoryRepository {
  /// Save [category] in database
  Future<AppResult<Null>> save({
    required IncomeCategory category,
    required String traceId,
  });

  /// Watch all [IncomeCategory] from database
  Stream<AppResult<List<IncomeCategory>>> watch({
    required String traceId,
    String? query,
    bool? isDeleted,
  });

  /// Delete [category] from database
  Future<AppResult<Null>> delete({
    required IncomeCategory category,
    required String traceId,
  });

  /// Update [updatedCategory] in database
  Future<AppResult<Null>> update({
    required IncomeCategory updatedCategory,
    required String traceId,
  });
}
