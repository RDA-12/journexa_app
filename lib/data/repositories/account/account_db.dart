import 'package:drift/drift.dart';
import 'package:journexa_app/data/database.dart';
import 'package:journexa_app/domain/entities/account.dart';

/// Local table for [Account]
class AccountDB extends Table {
  /// Unique code for each [Account]
  late final Column<String> code = text()();

  /// Name of the [Account]
  late final Column<String> name = text()();

  /// Type of the [Account]
  late final Column<String> type = text()();

  /// Whether the [Account] is a system [Account]
  late final Column<bool> isSystemAccount = boolean().clientDefault(
    () => false,
  )();

  /// Whether the [Account] is deleted
  late final Column<bool> isDeleted = boolean().clientDefault(() => false)();

  /// Parent code of the [Account]
  late final Column<String>? parentCode = text().nullable().references(
    AccountDB,
    #code,
  )();

  @override
  Set<Column<Object>> get primaryKey => {code};
}

/// Extension to provides helpers on [AccountDBData]
extension AccountDBDataX on AccountDBData {
  /// Return [Account] from this [AccountDBData]
  Account toDomain({Account? parent}) {
    final code = AccountCode.fromString(this.code);
    return Account(
      code: code,
      name: name,
      type: AccountType.fromKey(type),
      isSystemAccount: isSystemAccount,
      parent: parent,
    );
  }
}

/// Extension to provides helpers on [Account]
extension AccountX on Account {
  /// Return [AccountDBData] from this [Account]
  AccountDBCompanion toDB() {
    return AccountDBCompanion.insert(
      code: code.value,
      name: name,
      type: type.key,
      isSystemAccount: Value(isSystemAccount),
      parentCode: Value(parent?.code.value),
    );
  }
}
