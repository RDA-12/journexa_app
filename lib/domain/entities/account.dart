import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:journexa_app/shared/app_exception.dart';

part 'account.freezed.dart';

/// Types of [Account]
enum AccountType {
  /// Asset account
  ///
  /// Typically uses to holds value like wallet, bank, accounts receivable, etc
  asset,

  /// Revenue account
  ///
  /// Typically uses to holds income value
  revenue,

  /// Liability account
  ///
  /// Typically uses to holds debt value like accounts payable, loans, etc
  liability,

  /// Expense account
  ///
  /// Typically uses to holds expense value like rent, salaries, utilities, etc
  expense,

  /// Equity account
  ///
  /// Typically uses to holds owner's equity value like capital, drawings, etc
  equity;

  /// Return prefix code based on standard accounting practice
  String get prefixCode => switch (this) {
    AccountType.asset => '1',
    AccountType.liability => '2',
    AccountType.equity => '3',
    AccountType.revenue => '4',
    AccountType.expense => '5',
  };

  /// Return list of [AccountType] that have debit normal balance
  static List<AccountType> get debitNormalBalance => [
    AccountType.asset,
    AccountType.expense,
  ];

  /// Return list of [AccountType] that have credit normal balance
  static List<AccountType> get creditNormalBalance => [
    AccountType.liability,
    AccountType.equity,
    AccountType.revenue,
  ];

  /// Return key for this account type
  String get key => switch (this) {
    AccountType.asset => 'asset',
    AccountType.liability => 'liability',
    AccountType.equity => 'equity',
    AccountType.revenue => 'revenue',
    AccountType.expense => 'expense',
  };

  /// Return [AccountType] from [key].
  static AccountType fromKey(String key) {
    return switch (key) {
      'asset' => AccountType.asset,
      'liability' => AccountType.liability,
      'equity' => AccountType.equity,
      'revenue' => AccountType.revenue,
      'expense' => AccountType.expense,
      _ => throw AppException(
        'invalid account type: $key',
        code: AppExceptionCode.internalException,
      ),
    };
  }
}

/// Types of balance
enum BalanceType {
  /// Debit balance
  debit,

  /// Credit balance
  credit,
}

/// Holds system defined accounts
abstract class SystemDefinedAccount {
  /// Root asset account.
  static Account get rootAsset => Account(
    code: '10.0000',
    name: 'asset',
    type: AccountType.asset,
    isSystemAccount: true,
  );

  /// Root revenue account.
  static Account get rootRevenue => Account(
    code: '40.0000',
    name: 'revenue',
    type: AccountType.revenue,
    isSystemAccount: true,
  );

  /// Root expense account.
  static Account get rootExpense => Account(
    code: '50.0000',
    name: 'expense',
    type: AccountType.expense,
    isSystemAccount: true,
  );

  /// Default expense account for transfer transaction fee
  static Account get feeTransfer => Account(
    code: '50.0001',
    name: 'transfer fee',
    type: AccountType.expense,
    isSystemAccount: true,
    parent: rootExpense,
  );

  /// All system defined accounts
  static List<Account> get accounts => [
    rootAsset,
    rootRevenue,
    rootExpense,
    feeTransfer,
  ];
}

/// Represent single account in a double-entry accounting system
@freezed
sealed class Account with _$Account {
  /// Creates new [Account]
  factory Account({
    /// Unique code for an [Account]
    ///
    /// Code will be formatted as `<SystemCode>.<UserCreatedCode>`
    /// - SystemCode will have 2 digits.
    /// - UserCreatedCode will have 4 digits.
    required String code,

    /// Unique name of the [Account]
    required String name,

    /// Type of the [Account]
    required AccountType type,

    /// Parent [Account] of this [Account]
    Account? parent,

    /// Whether this [Account] is defined by system or not
    @Default(false) bool isSystemAccount,
  }) = _Account;

  /// Creates new [Account] to helps testing
  factory Account.test([AccountType type = AccountType.asset]) => Account(
    code: '${type.prefixCode}0.0000',
    name: 'test',
    type: type,
  );

  /// Creates new [Account] which code is derived from parent code
  factory Account.user({
    required Account parent,
    required String name,
    required int currentChildrenCount,
  }) {
    final nextUserCode = (currentChildrenCount + 1).toString().padLeft(4, '0');
    final code = '${parent.code.split('.')[0]}.$nextUserCode';

    return Account(
      code: code,
      name: name,
      type: parent.type,
      parent: parent,
    );
  }

  Account._() {
    if (!code.startsWith(type.prefixCode)) {
      throw AppException(
        'account with type $type '
        'must have code prefixed with ${type.prefixCode}. '
        'got ${code[0]} instead',
        code: AppExceptionCode.internalException,
      );
    }
    final splitted = code.split('.');
    if (splitted.length != 2) {
      throw AppException(
        'invalid code length. '
        'it must have 2 parts, system and user code, splitted by ".". '
        'got $splitted instead',
        code: AppExceptionCode.internalException,
      );
    }
    final systemCode = splitted[0];
    if (systemCode.length != 2) {
      throw AppException(
        'invalid system part in code, it must 2 character long. '
        'got $systemCode instead',
        code: AppExceptionCode.internalException,
      );
    }
    final userCode = splitted[1];
    if (userCode.length != 4) {
      throw AppException(
        'invalid user part in code, it must 4 character long. '
        'got $userCode instead',
        code: AppExceptionCode.internalException,
      );
    }
  }

  /// Return normal balance of this [Account].
  ///
  /// Normal balance means balance that needed to be increased
  /// when the amount added to the account is positive value.
  BalanceType get normalBalance {
    if (AccountType.debitNormalBalance.contains(type)) {
      return BalanceType.debit;
    } else {
      return BalanceType.credit;
    }
  }

  /// Update this [Account] based on args
  Account update({String? name}) {
    return copyWith(name: name ?? this.name);
  }
}
