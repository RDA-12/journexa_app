import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/expense_category.dart';

part 'firestore_expense_category.freezed.dart';
part 'firestore_expense_category.g.dart';

/// Firestore model for [ExpenseCategory]
@freezed
sealed class FirestoreExpenseCategory with _$FirestoreExpenseCategory {
  /// Creates new [FirestoreExpenseCategory]
  const factory FirestoreExpenseCategory({
    /// Unique ID of the category
    required String id,

    /// Name of the category
    required String name,

    /// Lowercase name of the category
    ///
    /// Used for search
    required String nameLower,

    /// Icon of the category
    required String icon,

    /// Account code of the category
    required String accountCode,
  }) = _FirestoreExpenseCategory;
  const FirestoreExpenseCategory._();

  //// Creates new [FirestoreExpenseCategory] from [domain]
  factory FirestoreExpenseCategory.fromDomain(ExpenseCategory domain) {
    return FirestoreExpenseCategory(
      id: domain.id,
      name: domain.name,
      nameLower: domain.name.toLowerCase(),
      icon: domain.icon,
      accountCode: domain.account.code,
    );
  }

  /// Creates new [FirestoreExpenseCategory] from [json]
  factory FirestoreExpenseCategory.fromJson(Map<String, Object?> json) =>
      _$FirestoreExpenseCategoryFromJson(json);

  /// Converts this to [ExpenseCategory] with [account]
  ExpenseCategory toDomain(Account account) {
    return ExpenseCategory(
      id: id,
      name: name,
      icon: icon,
      account: account,
    );
  }
}
