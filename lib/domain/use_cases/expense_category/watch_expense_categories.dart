import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/entities/expense_category.dart';
import 'package:journexa_app/domain/repositories/i_expense_category_repository.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';

part 'watch_expense_categories.freezed.dart';

/// Params for [WatchExpenseCategoriesUseCase]
@freezed
sealed class WatchExpenseCategoriesParams with _$WatchExpenseCategoriesParams {
  const factory WatchExpenseCategoriesParams({
    String? query,
  }) = _WatchExpenseCategoriesParams;
}

/// Use case to stream expense categories saved on
/// current user database
@lazySingleton
class WatchExpenseCategoriesUseCase
    with Loggable
    implements
        StreamBaseUseCase<WatchExpenseCategoriesParams, List<ExpenseCategory>> {
  /// Creates new [WatchExpenseCategoriesUseCase]
  WatchExpenseCategoriesUseCase({
    required this._expenseCategoryRepository,
  });

  @override
  String get logTag => 'WatchExpenseCategoriesUseCase';

  final IExpenseCategoryRepository _expenseCategoryRepository;

  /// Execute getting stream expense categories from current user
  @override
  Stream<AppResult<List<ExpenseCategory>>> execute(
    WatchExpenseCategoriesParams params, {
    required String traceId,
  }) {
    logInfo(
      'Starts getting expense categories',
      traceId: traceId,
    );
    return _expenseCategoryRepository.watch(
      query: params.query,
      traceId: traceId,
      isDeleted: false,
    );
  }
}
