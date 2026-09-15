import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/domain/repositories/i_income_category_repository.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';

part 'watch_income_categories.freezed.dart';

/// Params for [WatchIncomeCategoriesUseCase]
@freezed
sealed class WatchIncomeCategoriesParams with _$WatchIncomeCategoriesParams {
  const factory({
    String? query,
  }) = _WatchIncomeCategoriesParams;
}

/// Use case to stream income categories saved on
/// current user database
@lazySingleton
class WatchIncomeCategoriesUseCase
    with Loggable
    implements
        StreamBaseUseCase<WatchIncomeCategoriesParams, List<IncomeCategory>> {
  /// Creates new [WatchIncomeCategoriesUseCase]
  new({
    required this._incomeCategoryRepository,
  });

  @override
  String get logTag => 'WatchIncomeCategoriesUseCase';

  final IIncomeCategoryRepository _incomeCategoryRepository;

  /// Execute getting stream income categories from current user
  @override
  Stream<AppResult<List<IncomeCategory>>> execute(
    WatchIncomeCategoriesParams params, {
    required String traceId,
  }) {
    logInfo(
      'Starts getting income categories',
      traceId: traceId,
    );
    return _incomeCategoryRepository.watch(
      query: params.query,
      traceId: traceId,
      isDeleted: false,
    );
  }
}
