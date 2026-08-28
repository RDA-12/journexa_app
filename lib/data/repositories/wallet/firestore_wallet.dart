import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/wallet.dart';

part 'firestore_wallet.freezed.dart';
part 'firestore_wallet.g.dart';

/// Firestore representations of [Wallet]
@freezed
sealed class FirestoreWallet with _$FirestoreWallet {
  /// Creates new [FirestoreWallet]
  const factory FirestoreWallet({
    /// ID of the [FirestoreWallet]
    required String id,

    /// Name of this wallet
    required String name,

    /// Lower version of [name]
    required String nameLower,

    /// Account code of this wallet
    required String accountCode,

    /// Whether this wallet is deleted
    @Default(false) bool isDeleted,
  }) = _FirestoreWallet;

  /// Converts from JSON to [FirestoreWallet]
  factory FirestoreWallet.fromJson(Map<String, dynamic> json) =>
      _$FirestoreWalletFromJson(json);
  const FirestoreWallet._();

  /// Creates new [FirestoreWallet] based on [wallet]
  factory FirestoreWallet.fromDomain(Wallet wallet) => FirestoreWallet(
    id: wallet.id,
    name: wallet.name,
    nameLower: wallet.name.toLowerCase(),
    accountCode: wallet.account.code,
  );

  /// Converts to [Wallet]
  Wallet toDomain(Account account) => Wallet(
    id: id,
    name: name,
    account: account,
  );
}
