import 'package:drift/drift.dart';
import 'package:journexa_app/data/database.dart';
import 'package:journexa_app/data/repositories/account/account_db.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/wallet.dart';

/// Local table for [Wallet]
class WalletDB extends Table {
  /// Unique ID of [Wallet]
  late final Column<String> id = text()();

  /// Name of the [Wallet]
  late final Column<String> name = text().unique()();

  /// Whether the [Wallet] is deleted
  late final Column<bool> isDeleted = boolean().clientDefault(() => false)();

  /// Account code of the [Wallet]
  late final Column<String> accountCode = text().references(
    AccountDB,
    #code,
  )();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Extension to provide helpers on [WalletDBData]
extension WalletDBDataX on WalletDBData {
  /// Return [Wallet] from this [WalletDBData]
  Wallet toDomain({required Account account}) {
    return Wallet(
      id: id,
      name: name,
      account: account,
    );
  }
}

/// Extension to provide helpers on [Wallet]
extension WalletX on Wallet {
  /// Return [WalletDBCompanion] from this [Wallet]
  WalletDBCompanion toDB() {
    return WalletDBCompanion.insert(
      id: id,
      name: name,
      accountCode: account.code,
    );
  }
}
