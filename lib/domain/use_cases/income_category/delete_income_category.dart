import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/repositories/i_income_category.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';

part 'delete_income_category.freezed.dart';

/// Params for [DeleteIncomeCategoryUseCase]
@freezed
sealed class DeleteIncomeCategoryParams with _$DeleteIncomeCategoryParams {
  /// Creates new [DeleteIncomeCategoryParams]
  const factory DeleteIncomeCategoryParams({
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
  DeleteIncomeCategoryUseCase({
    required this._authRepository,
    required this._incomeCategoryRepository,
  });

  @override
  String get logTag => 'DeleteIncomeCategoryUseCase';

  final IAuthRepository _authRepository;
  final IIncomeCategoryRepository _incomeCategoryRepository;

  /// Execute deletting income category in [params] for current user
  @override
  Future<AppResult<Null>> execute(
    DeleteIncomeCategoryParams params, {
    required String traceId,
  }) async {
    logInfo('Starts getting current user id', traceId: traceId);
    final userIdResult = await _authRepository.getCurrentUserId(
      traceId: traceId,
    );
    final userIdExc = userIdResult.errorOrNull;
    if (userIdExc != null) {
      logInfo('Failed to get current user id', traceId: traceId);
      return AppResult.failure(userIdExc);
    }

    logInfo(
      'User id obtained. Start delete category',
      traceId: traceId,
      extras: {'id': params.category.id},
    );
    final userId = userIdResult.valueOrNull!;
    final deleteResult = await _incomeCategoryRepository.delete(
      userId: userId,
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
