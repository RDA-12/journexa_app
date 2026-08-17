import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:journexa_app/domain/entities/account.dart';

part 'firestore_account.freezed.dart';
part 'firestore_account.g.dart';

/// Firestore model representation of [Account]
@freezed
sealed class FirestoreAccount with _$FirestoreAccount {
  /// Creates new [FirestoreAccount]
  const factory FirestoreAccount({
    required String code,
    required String name,
    required String nameLower,
    required AccountType type,
    @Default(false) bool isSystemAccount,
    @Default(false) bool isDeleted,
    String? parentCode,
  }) = _FirestoreAccount;
  const FirestoreAccount._();

  factory FirestoreAccount.fromDomain(Account domain) {
    return FirestoreAccount(
      code: domain.code,
      name: domain.name,
      nameLower: domain.name.toLowerCase(),
      type: domain.type,
      isSystemAccount: domain.isSystemAccount,
      parentCode: domain.parent?.code,
    );
  }

  /// Creates [FirestoreAccount] from [json]
  factory FirestoreAccount.fromJson(Map<String, Object?> json) =>
      _$FirestoreAccountFromJson(json);

  /// Returns [Account] from this
  Account toDomain() {
    return Account(
      code: code,
      name: name,
      type: type,
      isSystemAccount: isSystemAccount,
    );
  }
}
