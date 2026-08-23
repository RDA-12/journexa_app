import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/income_category.dart';

part 'firestore_income_category.freezed.dart';
part 'firestore_income_category.g.dart';

/// Firestore model for [IncomeCategory]
@freezed
sealed class FirestoreIncomeCategory with _$FirestoreIncomeCategory {
  /// Creates new [FirestoreIncomeCategory]
  const factory FirestoreIncomeCategory({
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
  }) = _FirestoreIncomeCategory;
  const FirestoreIncomeCategory._();

  //// Creates new [FirestoreIncomeCategory] from [domain]
  factory FirestoreIncomeCategory.fromDomain(IncomeCategory domain) {
    return FirestoreIncomeCategory(
      id: domain.id,
      name: domain.name,
      nameLower: domain.name.toLowerCase(),
      icon: domain.icon,
      accountCode: domain.account.code,
    );
  }

  /// Creates new [FirestoreIncomeCategory] from [json]
  factory FirestoreIncomeCategory.fromJson(Map<String, Object?> json) =>
      _$FirestoreIncomeCategoryFromJson(json);

  /// Converts this to [IncomeCategory] with [account]
  IncomeCategory toDomain(Account account) {
    return IncomeCategory(
      id: id,
      name: name,
      icon: icon,
      account: account,
    );
  }
}
