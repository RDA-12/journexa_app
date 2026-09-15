import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/domain/repositories/i_account_repository.dart';
import 'package:journexa_app/domain/repositories/i_income_category_repository.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';

part 'add_income_category.freezed.dart';

/// Params for [AddIncomeCategoryUseCase]
@freezed
sealed class AddIncomeCategoryParams with _$AddIncomeCategoryParams {
  const factory({
    /// Name of the category
    required String name,
  }) = _AddIncomeCategoryParams;
  const new _();

  /// Return extras of this params meant to be used in logger
  Map<String, String> get extras => {'name': name};
}

/// Use case to creates new income category
@lazySingleton
class AddIncomeCategoryUseCase
    with Loggable, GenerateUid
    implements FutureBaseUseCase<AddIncomeCategoryParams, Null> {
  /// Creates new [AddIncomeCategoryUseCase]
  new({
    required this._accountRepository,
    required this._incomeCategoryRepository,
  });

  final IAccountRepository _accountRepository;
  final IIncomeCategoryRepository _incomeCategoryRepository;

  @override
  String get logTag => 'AddIncomeCategoryUseCase';

  @override
  Future<AppResult<Null>> execute(
    AddIncomeCategoryParams params, {
    required String traceId,
  }) async {
    logInfo(
      'Start adding new income category',
      traceId: traceId,
      extras: params.extras,
    );
    logInfo('Get parent Account for revenue', traceId: traceId);
    final parentRevenueAccount = SystemDefinedAccount.incomeParent;
    logInfo(
      'Revenue parent Account obtained. Get children count',
      traceId: traceId,
    );

    final getChildrenCountResult = await _accountRepository
        .getChildrenCountByParentCode(
          parentCode: parentRevenueAccount.code.value,
          traceId: traceId,
        );
    final getChildrenCountExc = getChildrenCountResult.errorOrNull;
    if (getChildrenCountExc != null) {
      logInfo(
        'Failed to get children count for revenue parent Account.',
        traceId: traceId,
      );
      return AppResult.failure(getChildrenCountExc);
    }
    final childrenCount = getChildrenCountResult.valueOrNull!;
    logInfo(
      'children count obtained. '
      'Creating new Account and IncomeCategory object',
      traceId: traceId,
    );

    final newAccount = Account.sub(
      parent: parentRevenueAccount,
      name: params.name,
      currentChildrenCount: childrenCount,
    );
    final newCategory = IncomeCategory(
      id: generateUid(),
      name: params.name,
      icon: 'icon',
      account: newAccount,
    );
    logInfo('New objects created. Saving IncomeCategory', traceId: traceId);

    final saveResult = await _incomeCategoryRepository.save(
      category: newCategory,
      traceId: traceId,
    );
    return await saveResult.when(
      success: (_) {
        logInfo(
          'new IncomeCategory saved successfully. Done.',
          traceId: traceId,
        );
        return const AppResult<Null>.success(null);
      },
      failure: (exc) {
        logInfo('Failed to save new IncomeCategory', traceId: traceId);
        return AppResult.failure(exc);
      },
    );
  }
}
