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
  /// Wallet parent account
  static Account get walletParent => Account.root(
    name: 'wallet',
    type: AccountType.asset,
    systemCode: '001',
  );

  /// Income parent account
  static Account get incomeParent => Account.root(
    name: 'income',
    type: AccountType.revenue,
    systemCode: '001',
  );

  /// Expense parent account
  static Account get expenseParent => Account.root(
    name: 'expense',
    type: AccountType.expense,
    systemCode: '001',
  );

  /// Default expense account for transfer transaction fee
  static Account get feeTransfer => Account.sub(
    parent: expenseParent,
    name: 'transfer fee',
    currentChildrenCount: 0,
    isSystemAccount: true,
  );

  /// All system defined accounts
  static List<Account> get accounts => [
    walletParent,
    incomeParent,
    expenseParent,
    feeTransfer,
  ];
}

/// Represent account code structure
///
/// It will formed `<typeCode>.<systemCode>.<subCodes>...`.
/// `<typeCode>` is 1 digit code based on [AccountType].
/// `<systemCode>` is 3 digits code defined by system.
/// `<subCodes>` is 3 digits sub code
///
/// For example:
/// `1.001.001`:
/// - 1 -> asset type
/// - 001 -> 3-digits system code, e.g. wallet
/// - 001 -> sub code
///
/// NOTE: specific for root accounts (asset,liability,revenue,expense,equity),
/// it will only have `<typeCode>`
@freezed
sealed class AccountCode with _$AccountCode {
  /// Creates new [AccountCode]
  factory({
    /// Type code of the [Account]
    required String typeCode,

    /// Code defined by system (e.g. "000")
    required String systemCode,

    /// Sub code (e.g. [001, 002])
    required List<String> subCodes,
  }) = _AccountCode;
  new _() {
    if (!AccountType.values.any((e) => e.prefixCode == typeCode)) {
      throw AppException(
        'invalid account type code. Got $typeCode. '
        'Expected one of ${AccountType.values.map((e) => e.prefixCode)}',
        code: AppExceptionCode.internalException,
      );
    }
    if (systemCode.length != 3) {
      throw AppException(
        'invalid system code length. Got ${systemCode.length}. '
        'Expected 3 characters',
        code: AppExceptionCode.internalException,
      );
    }
    if (int.tryParse(systemCode) == null) {
      throw AppException(
        'invalid system code format. Got $systemCode. '
        'Expected digits',
        code: AppExceptionCode.internalException,
      );
    }
    for (final (index, code) in subCodes.indexed) {
      if (code.length != 3) {
        throw AppException(
          'invalid sub code length at $index. Got ${code.length}. '
          'Expected 3 characters',
          code: AppExceptionCode.internalException,
        );
      }
      if (int.tryParse(code) == null) {
        throw AppException(
          'invalid sub code format at $index. Got $code. '
          'Expected digits',
          code: AppExceptionCode.internalException,
        );
      }
    }
  }

  /// Creates new [AccountCode] for root account
  factory root({
    required AccountType type,
    required String systemCode,
  }) => AccountCode(
    typeCode: type.prefixCode,
    systemCode: systemCode,
    subCodes: [],
  );

  /// Creates new [AccountCode] for sub account
  factory sub({
    required Account parent,
    required String subCode,
  }) => AccountCode(
    typeCode: parent.code.typeCode,
    systemCode: parent.code.systemCode,
    subCodes: [
      ...parent.code.subCodes,
      subCode,
    ],
  );

  /// Parse [AccountCode] from [String]
  ///
  /// [code] must be in format `<typeCode>.<systemCode>.<subCodes>...`
  factory fromString(String code) {
    final codes = code.split('.');
    if (codes.length < 2) {
      throw AppException(
        'invalid account code format. Got $code. ',
        code: AppExceptionCode.internalException,
      );
    }
    final typeCode = codes[0];
    final systemCode = codes[1];
    final subCodes = codes.sublist(2);
    return AccountCode(
      typeCode: typeCode,
      systemCode: systemCode,
      subCodes: subCodes,
    );
  }

  @override
  String toString() {
    final codes = [typeCode, systemCode, ...subCodes];
    return codes.join('.');
  }

  /// Get formatted [AccountCode] with dots (e.g. "1.001.001")
  String get value => toString();

  /// Returns whether this code represents a root account
  bool get isRoot => subCodes.isEmpty;

  /// Returns whether this code represents a sub account
  bool get isSub => !isRoot;
}

/// Represent single account in a double-entry accounting system
@freezed
sealed class Account with _$Account {
  /// Creates new [Account]
  factory({
    /// Unique code for an [Account]
    required AccountCode code,

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
  factory test([AccountType type = AccountType.asset]) => Account(
    code: AccountCode.root(type: type, systemCode: '001'),
    name: 'test',
    type: type,
  );

  /// Creates new [Account] that will be sub account
  ///
  /// It will create code by appending `<currentChildrenCount + 1>` to
  /// parent's [AccountCode].
  factory sub({
    required Account parent,
    required String name,
    required int currentChildrenCount,
    bool isSystemAccount = false,
  }) {
    final code = (currentChildrenCount + 1).toString().padLeft(3, '0');

    return Account(
      code: AccountCode.sub(parent: parent, subCode: code),
      name: name,
      type: parent.type,
      parent: parent,
      isSystemAccount: isSystemAccount,
    );
  }

  /// Creates new [Account] for root accounts
  factory root({
    required String name,
    required AccountType type,
    required String systemCode,
  }) => Account(
    code: AccountCode.root(type: type, systemCode: systemCode),
    name: name,
    type: type,
    isSystemAccount: true,
  );

  new _();

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
