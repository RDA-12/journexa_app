import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/shared/app_exception.dart';

part 'expense_category.freezed.dart';

/// Representing single expense category
@freezed
sealed class ExpenseCategory with _$ExpenseCategory {
  /// Creates new expense category
  factory({
    /// Unique identifier
    required String id,

    /// name of this expense
    required String name,

    /// icon for this expense
    required String icon,

    /// [Account] for this category
    required Account account,
  }) = _ExpenseCategory;

  /// Creates new [ExpenseCategory] for testing
  factory test() => ExpenseCategory(
    id: 'id',
    name: 'name',
    icon: 'icon',
    account: Account.test(AccountType.expense).copyWith(
      parent: SystemDefinedAccount.expenseParent,
    ),
  );

  new _() {
    if (account.type != AccountType.expense) {
      throw AppException(
        'ExpenseCategory must have expense typed Account. Got: ${account.type}',
        code: AppExceptionCode.internalException,
      );
    }
    if (account.parent != SystemDefinedAccount.expenseParent) {
      throw AppException(
        'ExpenseCategory must have Account with parent to system expense '
        'Account. Got: ${account.parent}',
        code: AppExceptionCode.internalException,
      );
    }
  }

  /// Returns updated of this based on provided parameters.
  ExpenseCategory update({String? name}) {
    var updated = this;
    if (name != null) {
      updated = updated.copyWith(
        name: name,
        account: account.copyWith(name: name),
      );
    }
    return updated;
  }
}
