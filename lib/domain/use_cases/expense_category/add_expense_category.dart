import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/expense_category.dart';
import 'package:journexa_app/domain/repositories/i_account_repository.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/repositories/i_expense_category.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';

part 'add_expense_category.freezed.dart';

/// Params for [AddExpenseCategoryUseCase]
@freezed
sealed class AddExpenseCategoryParams with _$AddExpenseCategoryParams {
  const factory AddExpenseCategoryParams({
    /// Name of the category
    required String name,
  }) = _AddExpenseCategoryParams;
  const AddExpenseCategoryParams._();

  /// Return extras of this params meant to be used in logger
  Map<String, String> get extras => {'name': name};
}

/// Use case to creates new expense category
@lazySingleton
class AddExpenseCategoryUseCase
    with Loggable, GenerateUid
    implements FutureBaseUseCase<AddExpenseCategoryParams, Null> {
  /// Creates new [AddExpenseCategoryUseCase]
  AddExpenseCategoryUseCase({
    required this._authRepository,
    required this._accountRepository,
    required this._expenseCategoryRepository,
  });

  final IAuthRepository _authRepository;
  final IAccountRepository _accountRepository;
  final IExpenseCategoryRepository _expenseCategoryRepository;

  @override
  String get logTag => 'AddExpenseCategoryUseCase';

  @override
  Future<AppResult<Null>> execute(
    AddExpenseCategoryParams params, {
    required String traceId,
  }) async {
    logInfo(
      'Start adding new expense category. Get current user id',
      traceId: traceId,
      extras: params.extras,
    );
    final getCurrentUserIdResult = await _authRepository.getCurrentUserId(
      traceId: traceId,
    );
    final getCurrentUserIdExc = getCurrentUserIdResult.errorOrNull;
    if (getCurrentUserIdExc != null) {
      logInfo(
        'Failed to get current user id.',
        traceId: traceId,
      );
      return AppResult.failure(getCurrentUserIdExc);
    }

    logInfo('userId obtained', traceId: traceId);
    final userId = getCurrentUserIdResult.valueOrNull!;
    logInfo('Get parent Account for expense', traceId: traceId);
    final parentExpenseAccount = SystemDefinedAccount.rootExpense;
    logInfo(
      'Expense parent Account obtained. Get children count',
      traceId: traceId,
    );

    final getChildrenCountResult = await _accountRepository
        .getChildrenCountByParentCode(
          userId: userId,
          parentCode: parentExpenseAccount.code,
          traceId: traceId,
        );
    final getChildrenCountExc = getChildrenCountResult.errorOrNull;
    if (getChildrenCountExc != null) {
      logInfo(
        'Failed to get children count for expense parent Account.',
        traceId: traceId,
      );
      return AppResult.failure(getChildrenCountExc);
    }
    final childrenCount = getChildrenCountResult.valueOrNull!;
    logInfo(
      'children count obtained. '
      'Creating new Account and ExpenseCategory object',
      traceId: traceId,
    );

    final newAccount = Account.user(
      parent: parentExpenseAccount,
      name: params.name,
      currentChildrenCount: childrenCount,
    );
    final newCategory = ExpenseCategory(
      id: generateUid(),
      name: params.name,
      icon: 'icon',
      account: newAccount,
    );
    logInfo('New objects created. Saving ExpenseCategory', traceId: traceId);

    final saveResult = await _expenseCategoryRepository.save(
      userId: userId,
      category: newCategory,
      traceId: traceId,
    );
    return saveResult.when(
      success: (_) {
        logInfo(
          'new ExpenseCategory saved successfully. Done.',
          traceId: traceId,
        );
        return const AppResult<Null>.success(null);
      },
      failure: (exc) {
        logInfo('Failed to save new ExpenseCategory', traceId: traceId);
        return AppResult.failure(exc);
      },
    );
  }
}
