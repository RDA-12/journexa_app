import 'package:drift/drift.dart';
import 'package:journexa_app/data/database.dart';
import 'package:journexa_app/data/repositories/account/account_db.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/income_category.dart';

/// Local table for [IncomeCategory]
class IncomeCategoryDB extends Table {
  /// Unique ID of [IncomeCategory]
  late final Column<String> id = text()();

  /// Name of the [IncomeCategory]
  late final Column<String> name = text().unique()();

  /// Icon of the [IncomeCategory]
  late final Column<String> icon = text()();

  /// Whether the [IncomeCategory] is deleted
  late final Column<bool> isDeleted = boolean().clientDefault(() => false)();

  /// Account code of the [IncomeCategory]
  late final Column<String> accountCode = text().references(
    AccountDB,
    #code,
  )();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Extension to provides helpers on [IncomeCategoryDBData]
extension IncomeCategoryDBDataX on IncomeCategoryDBData {
  /// Return [IncomeCategory] from this [IncomeCategoryDBData]
  IncomeCategory toDomain({required Account account}) {
    return IncomeCategory(
      id: id,
      name: name,
      icon: icon,
      account: account,
    );
  }
}

/// Extension to provides helpers on [IncomeCategory]
extension IncomeCategoryX on IncomeCategory {
  /// Return [IncomeCategoryDBCompanion] from this [IncomeCategory]
  IncomeCategoryDBCompanion toDB() {
    return IncomeCategoryDBCompanion.insert(
      id: id,
      name: name,
      icon: icon,
      accountCode: account.code,
    );
  }
}
