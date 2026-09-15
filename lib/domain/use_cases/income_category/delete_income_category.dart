import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/domain/repositories/i_income_category_repository.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';

part 'delete_income_category.freezed.dart';

/// Params for [DeleteIncomeCategoryUseCase]
@freezed
sealed class DeleteIncomeCategoryParams with _$DeleteIncomeCategoryParams {
  /// Creates new [DeleteIncomeCategoryParams]
  const factory({
    /// [IncomeCategory] that will be deleted
    required IncomeCategory category,
  }) = _DeleteIncomeCategorysParams;
}

/// Use Case to delete an income category in current user database
@lazySingleton
class DeleteIncomeCategoryUseCase
    with Loggable
    implements FutureBaseUseCase<DeleteIncomeCategoryParams, Null> {
  /// Creates new [DeleteIncomeCategoryUseCase]
  new({
    required this._incomeCategoryRepository,
  });

  @override
  String get logTag => 'DeleteIncomeCategoryUseCase';

  final IIncomeCategoryRepository _incomeCategoryRepository;

  /// Execute deletting income category in [params] for current user
  @override
  Future<AppResult<Null>> execute(
    DeleteIncomeCategoryParams params, {
    required String traceId,
  }) async {
    logInfo('Starts deleting', traceId: traceId);
    final deleteResult = await _incomeCategoryRepository.delete(
      category: params.category,
      traceId: traceId,
    );
    final deleteExc = deleteResult.errorOrNull;
    if (deleteExc != null) {
      logInfo('Failed to delete category', traceId: traceId);
      return AppResult.failure(deleteExc);
    }

    logInfo('IncomeCategory deleted successfully', traceId: traceId);
    return const AppResult.success(null);
  }
}
