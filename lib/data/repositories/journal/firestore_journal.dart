import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:journexa_app/domain/entities/journal.dart';
import 'package:journexa_app/shared/json_converter/json_converter.dart';

part 'firestore_journal.freezed.dart';
part 'firestore_journal.g.dart';

/// Firestore model for [AccountBalance]
@freezed
sealed class FirestoreAccountBalance with _$FirestoreAccountBalance {
  const factory FirestoreAccountBalance({
    /// Account code
    required String code,

    /// Current account balance
    @DecimalConverter() required Decimal balance,
  }) = _FirestoreAccountBalance;

  factory FirestoreAccountBalance.fromDomain(AccountBalance balance) =>
      FirestoreAccountBalance(
        code: balance.account.code,
        balance: balance.balance,
      );

  const FirestoreAccountBalance._();

  factory FirestoreAccountBalance.fromJson(Map<String, Object?> json) =>
      _$FirestoreAccountBalanceFromJson(json);
}

/// Firestore model for [JournalEntry]
@freezed
sealed class FirestoreJournalEntry with _$FirestoreJournalEntry {
  /// Creates new [FirestoreJournalEntry]
  const factory FirestoreJournalEntry({
    /// ID of this entry
    required String id,

    /// When this entry was happened
    @DateTimeConverter() required DateTime transactionDate,

    /// Optional notes
    String? notes,
  }) = _FirestoreJournalEntry;

  /// Creates new [FirestoreJournalEntry] from [json]
  factory FirestoreJournalEntry.fromJson(Map<String, Object?> json) =>
      _$FirestoreJournalEntryFromJson(json);

  /// Creates new [FirestoreJournalEntry] from [JournalEntry]
  factory FirestoreJournalEntry.fromDomain(JournalEntry entry) {
    return FirestoreJournalEntry(
      id: entry.id,
      transactionDate: entry.transactionDate,
      notes: entry.description,
    );
  }
}

/// Firestore model for [JournalEntryLine]
@freezed
sealed class FirestoreJournalEntryLine with _$FirestoreJournalEntryLine {
  /// Creates new [FirestoreJournalEntryLine]
  const factory FirestoreJournalEntryLine({
    /// Code of the account
    required String accountCode,

    /// Total debit of this line
    @DecimalConverter() required Decimal debit,

    /// Total credit of this line
    @DecimalConverter() required Decimal credit,
  }) = _FirestoreJournalEntryLine;

  /// Creates new [FirestoreJournalEntryLine] from [json]
  factory FirestoreJournalEntryLine.fromJson(Map<String, Object?> json) =>
      _$FirestoreJournalEntryLineFromJson(json);

  /// Creates new [FirestoreJournalEntryLine] from [JournalEntryLine]
  factory FirestoreJournalEntryLine.fromDomain(JournalEntryLine line) {
    return FirestoreJournalEntryLine(
      accountCode: line.account.code,
      debit: line.debit,
      credit: line.credit,
    );
  }
}
