import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/shared/app_exception.dart';

part 'journal.freezed.dart';

/// Represent single entry in a double-entry accounting system
@freezed
sealed class JournalEntry with _$JournalEntry {
  /// Creates new [JournalEntry]
  factory({
    /// ID of the entry
    required String id,

    /// When the entry was created
    required DateTime transactionDate,

    /// List of lines in this entry
    required List<JournalEntryLine> lines,

    /// Description of this entry
    String? description,
  }) = _JournalEntry;
  new _() {
    final debit = lines.fold(Decimal.zero, (sum, line) => sum + line.debit);
    final credit = lines.fold(Decimal.zero, (sum, line) => sum + line.credit);

    if (debit != credit) {
      throw AppException(
        'lines must be balanced. current debit: $debit, credit: $credit',
        code: AppExceptionCode.internalException,
      );
    }
  }

  /// Creates new [JournalEntry] for test purposes
  factory test({
    required DateTime transactionDate,
    List<JournalEntryLine> lines = const [],
    String? description,
  }) {
    return JournalEntry(
      id: 'id',
      transactionDate: transactionDate,
      lines: lines,
      description: description,
    );
  }
}

/// Represent single line in an entry in double-entry accounting system
@freezed
sealed class JournalEntryLine with _$JournalEntryLine {
  /// Creates new [JournalEntryLine]
  const factory({
    /// Account of this line
    required Account account,

    /// Debit amount
    required Decimal debit,

    /// Credit amount
    required Decimal credit,
  }) = _JournalEntryLine;
  const new _();

  factory fromAccount({
    required Account account,
    required Decimal amount,
  }) {
    final absAmount = amount.abs();
    if (account.normalBalance == BalanceType.credit) {
      if (amount > Decimal.zero) {
        return JournalEntryLine(
          account: account,
          debit: Decimal.zero,
          credit: absAmount,
        );
      } else {
        return JournalEntryLine(
          account: account,
          debit: absAmount,
          credit: Decimal.zero,
        );
      }
    } else {
      if (amount > Decimal.zero) {
        return JournalEntryLine(
          account: account,
          debit: absAmount,
          credit: Decimal.zero,
        );
      } else {
        return JournalEntryLine(
          account: account,
          debit: Decimal.zero,
          credit: absAmount,
        );
      }
    }
  }

  factory test() {
    return JournalEntryLine(
      account: Account.test(),
      debit: Decimal.zero,
      credit: Decimal.zero,
    );
  }
}
