import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/shared/app_exception.dart';

part 'wallet.freezed.dart';

/// Representing single wallet data users owned
@freezed
sealed class Wallet with _$Wallet {
  /// Creates new [Wallet]
  factory({
    /// Unique ID of this [Wallet]
    required String id,

    /// Name of the [Wallet]
    required String name,

    /// Accounting [Account] connected to this [Wallet]
    required Account account,
  }) = _Wallet;

  /// Creates new [Wallet] for testing purposes
  factory test() => Wallet(
    id: 'id',
    name: 'test',
    account: Account.test().copyWith(parent: SystemDefinedAccount.walletParent),
  );

  new _() {
    if (account.type != AccountType.asset) {
      throw AppException(
        'Wallet must have asset typed Account. Got: ${account.type}',
        code: AppExceptionCode.internalException,
      );
    }
    if (name != account.name) {
      throw AppException(
        'Account name must match Wallet name. '
        'Wallet name: $name, Account name: ${account.name}',
        code: AppExceptionCode.internalException,
      );
    }
    final assetParent = SystemDefinedAccount.walletParent;
    if (account.parent != assetParent) {
      throw AppException(
        'Wallet account must have asset parent. Got: ${account.parent?.code}',
        code: AppExceptionCode.internalException,
      );
    }
  }

  /// Returns updated [Wallet] based on provided arguments
  Wallet update({String? name}) {
    var updated = this;
    if (name != null) {
      updated = updated.copyWith(
        name: name,
        account: updated.account.copyWith(name: name),
      );
    }
    return updated;
  }
}
