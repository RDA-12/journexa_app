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
}
