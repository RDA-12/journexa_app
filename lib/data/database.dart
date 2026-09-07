import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/data/converter.dart';
import 'package:journexa_app/data/repositories/account/account.dart';
import 'package:journexa_app/data/repositories/expense_category/expense_category.dart';
import 'package:journexa_app/data/repositories/income_category/income_category.dart';
import 'package:journexa_app/data/repositories/journal/journal.dart';
import 'package:journexa_app/data/repositories/transaction/transaction.dart';
import 'package:journexa_app/data/repositories/wallet/wallet.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

/// Local app database
@lazySingleton
@DriftDatabase(
  tables: [
    AccountDB,
    ExpenseCategoryDB,
    IncomeCategoryDB,
    JournalEntryDB,
    JournalEntryLineDB,
    TransactionDB,
    WalletDB,
  ],
)
class AppLocalDatabase extends _$AppLocalDatabase {
  /// Creates new [AppLocalDatabase]
  @factoryMethod
  factory AppLocalDatabase() {
    final executor = driftDatabase(
      name: 'journexa_db',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
    return AppLocalDatabase._(executor);
  }

  /// Creates new [AppLocalDatabase] for testing
  @visibleForTesting
  factory AppLocalDatabase.test() {
    final executor = DatabaseConnection(
      NativeDatabase.memory(),
      closeStreamsSynchronously: true,
    );
    return AppLocalDatabase._(executor);
  }

  /// Creates new [AppLocalDatabase]
  AppLocalDatabase._(super.e);

  @override
  int get schemaVersion => 1;
}
