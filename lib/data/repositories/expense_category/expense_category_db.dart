import 'package:drift/drift.dart';
import 'package:journexa_app/data/database.dart';
import 'package:journexa_app/data/repositories/account/account_db.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/expense_category.dart';

/// Local table for [ExpenseCategory]
class ExpenseCategoryDB extends Table {
  /// Unique ID of [ExpenseCategory]
  late final Column<String> id = text()();

  /// Name of the [ExpenseCategory]
  late final Column<String> name = text().unique()();

  /// Icon of the [ExpenseCategory]
  late final Column<String> icon = text()();

  /// Whether the [ExpenseCategory] is deleted
  late final Column<bool> isDeleted = boolean().clientDefault(() => false)();

  /// Account code of the [ExpenseCategory]
  late final Column<String> accountCode = text().references(
    AccountDB,
    #code,
  )();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Extension to provides helpers on [ExpenseCategoryDBData]
extension ExpenseCategoryDBDataX on ExpenseCategoryDBData {
  /// Return [ExpenseCategory] from this [ExpenseCategoryDBData]
  ExpenseCategory toDomain({required Account account}) {
    return ExpenseCategory(
      id: id,
      name: name,
      icon: icon,
      account: account,
    );
  }
}

/// Extension to provides helpers on [ExpenseCategory]
extension ExpenseCategoryX on ExpenseCategory {
  /// Return [ExpenseCategoryDBCompanion] from this [ExpenseCategory]
  ExpenseCategoryDBCompanion toDB() {
    return ExpenseCategoryDBCompanion.insert(
      id: id,
      name: name,
      icon: icon,
      accountCode: account.code,
    );
  }
}
