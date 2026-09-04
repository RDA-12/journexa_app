import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/repositories/i_income_category_repository.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';

part 'update_income_category.freezed.dart';

/// Params for [UpdateIncomeCategoryUseCase]
@freezed
sealed class UpdateIncomeCategoryParams with _$UpdateIncomeCategoryParams {
  const factory UpdateIncomeCategoryParams({
    /// IncomeCategory code that will be updated
    required IncomeCategory category,

    /// Optional new name
    String? name,
  }) = _UpdateIncomeCategoryParams;
}

/// Use case to update existing [IncomeCategory] for current user
@lazySingleton
class UpdateIncomeCategoryUseCase
    with Loggable
    implements FutureBaseUseCase<UpdateIncomeCategoryParams, IncomeCategory> {
  /// Creates new [UpdateIncomeCategoryUseCase]
  UpdateIncomeCategoryUseCase({
    required this._authRepository,
    required this._incomeCategoryRepository,
  });

  @override
  String get logTag => 'UpdateIncomeCategoryUseCase';

  final IAuthRepository _authRepository;
  final IIncomeCategoryRepository _incomeCategoryRepository;

  /// Execute updating an [IncomeCategory]
  @override
  Future<AppResult<IncomeCategory>> execute(
    UpdateIncomeCategoryParams params, {
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
      'User id obtained. Starts updating the IncomeCategory',
      traceId: traceId,
      extras: {
        'id': params.category.id,
      },
    );
    final userId = userIdResult.valueOrNull!;
    final updatedCategory = params.category.update(
      name: params.name,
    );
    final saveResult = await _incomeCategoryRepository.update(
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
