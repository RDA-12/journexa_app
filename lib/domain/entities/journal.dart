import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/shared/app_exception.dart';

part 'journal.freezed.dart';

/// Represent single entry in a double-entry accounting system
@freezed
sealed class JournalEntry with _$JournalEntry {
  /// Creates new [JournalEntry]
  factory JournalEntry({
    /// ID of the entry
    required String id,

    /// When the entry was created
    required DateTime createdAt,

    /// List of lines in this entry
    required List<JournalEntryLine> lines,

    /// Description of this entry
    String? description,
  }) = _JournalEntry;
  JournalEntry._() {
    final debit = lines.fold(Decimal.zero, (sum, line) => sum + line.debit);
    final credit = lines.fold(Decimal.zero, (sum, line) => sum + line.credit);

    if (debit != credit) {
      throw AppException(
        'lines must be balanced. current debit: $debit, credit: $credit',
        code: AppExceptionCode.internalException,
      );
    }
  }
}

/// Represent single line in an entry in double-entry accounting system
@freezed
sealed class JournalEntryLine with _$JournalEntryLine {
  /// Creates new [JournalEntryLine]
  const factory JournalEntryLine({
    /// Account of this line
    required Account account,

    /// Debit amount
    required Decimal debit,

    /// Credit amount
    required Decimal credit,
  }) = _JournalEntryLine;
  const JournalEntryLine._();
}

/// Extension helper to constructs JournalEntry
extension JournalEntryX on Account {
  /// Creates new line for this [Account]
  JournalEntryLine createLine(Decimal amount) {
    final absAmount = amount.abs();
    if (normalBalance == BalanceType.credit) {
      if (amount > Decimal.zero) {
        return JournalEntryLine(
          account: this,
          debit: Decimal.zero,
          credit: absAmount,
        );
      } else {
        return JournalEntryLine(
          account: this,
          debit: absAmount,
          credit: Decimal.zero,
        );
      }
    } else {
      if (amount > Decimal.zero) {
        return JournalEntryLine(
          account: this,
          debit: absAmount,
          credit: Decimal.zero,
        );
      } else {
        return JournalEntryLine(
          account: this,
          debit: Decimal.zero,
          credit: absAmount,
        );
      }
    }
  }
}

/// Represent balance of a single [Account]
@freezed
sealed class AccountBalance with _$AccountBalance {
  /// Creates new [AccountBalance]
  const factory AccountBalance({
    /// Account of this balance
    required Account account,

    /// Current balance
    required Decimal balance,
  }) = _AccountBalance;
  const AccountBalance._();
}
