import 'package:drift/drift.dart';
import 'package:journexa_app/data/converter.dart';
import 'package:journexa_app/data/database.dart';
import 'package:journexa_app/data/repositories/account/account.dart';
import 'package:journexa_app/domain/entities/journal.dart';

/// Local DB for [JournalEntry]
class JournalEntryDB extends Table {
  /// ID of this [JournalEntry]
  late final Column<String> id = text()();

  /// Date when this [JournalEntry] was happened
  late final Column<String> transactionDate = text().map(
    const DriftDateTimeConverter(),
  )();

  /// Optional notes
  late final Column<String> notes = text().nullable()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

/// Local DB for [JournalEntryLine]
class JournalEntryLineDB extends Table {
  /// ID of this [JournalEntryLine]
  late final Column<String> id = text()();

  /// Total credit of this line
  late final Column<String> credit = text().map(
    const DriftDecimalConverter(),
  )();

  /// Total debit of this line
  late final Column<String> debit = text().map(const DriftDecimalConverter())();

  /// Code of the account
  late final Column<String> accountCode = text().references(AccountDB, #code)();

  /// ID of the [JournalEntry]
  late final Column<String> journalId = text().references(
    JournalEntryDB,
    #id,
  )();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

/// Extension to provide helpers on [JournalEntry]
extension JournalEntryX on JournalEntry {
  /// Return [JournalEntryDBCompanion] from this [JournalEntry]
  JournalEntryDBCompanion toDB() {
    return JournalEntryDBCompanion.insert(
      id: id,
      transactionDate: transactionDate,
      notes: Value(description),
    );
  }
}

/// Extension to provide helpers on [JournalEntryLine]
extension JournalEntryLineX on JournalEntryLine {
  /// Return [JournalEntryLineDBCompanion] from this [JournalEntryLine]
  JournalEntryLineDBCompanion toDB({
    required String id,
    required String journalId,
  }) {
    return JournalEntryLineDBCompanion.insert(
      id: id,
      credit: credit,
      debit: debit,
      accountCode: account.code,
      journalId: journalId,
    );
  }
}
