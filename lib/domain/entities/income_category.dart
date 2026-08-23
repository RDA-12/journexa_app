import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/shared/app_exception.dart';

part 'income_category.freezed.dart';

/// Representing single income category
@freezed
sealed class IncomeCategory with _$IncomeCategory {
  /// Creates new income category
  factory IncomeCategory({
    /// Unique identifier
    required String id,

    /// name of this income
    required String name,

    /// icon for this income
    required String icon,

    /// [Account] for this category
    required Account account,
  }) = _IncomeIncomeCategory;

  /// Creates new [IncomeCategory] for testing
  factory IncomeCategory.test() => IncomeCategory(
    id: 'id',
    name: 'name',
    icon: 'icon',
    account: Account.test(AccountType.revenue).copyWith(
      parent: SystemDefinedAccount.rootRevenue,
    ),
  );

  IncomeCategory._() {
    if (account.type != AccountType.revenue) {
      throw AppException(
        'IncomeCategory must have revenue typed Account. Got: ${account.type}',
        code: AppExceptionCode.internalException,
      );
    }
    if (account.parent != SystemDefinedAccount.rootRevenue) {
      throw AppException(
        'IncomeCategory must have Account with parent to system revenue '
        'Account. Got: ${account.parent}',
        code: AppExceptionCode.internalException,
      );
    }
  }
}
