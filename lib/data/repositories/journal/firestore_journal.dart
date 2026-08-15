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
