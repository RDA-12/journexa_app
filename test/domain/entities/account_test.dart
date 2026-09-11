import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/shared/app_exception.dart';

void main() {
  final expectedPrefixCode = {
    AccountType.asset: '1',
    AccountType.liability: '2',
    AccountType.equity: '3',
    AccountType.revenue: '4',
    AccountType.expense: '5',
  };

  group('AccountType', () {
    for (final type in AccountType.values) {
      test('$type should have ${expectedPrefixCode[type]} prefix code', () {
        expect(type.prefixCode, expectedPrefixCode[type]);
      });

      test('$type has valid fromKey mapping', () {
        expect(AccountType.fromKey(type.key), type);
      });
    }

    test('throws on invalid key', () {
      expect(
        () => AccountType.fromKey('invalid_key'),
        throwsA(isA<AppException>()),
      );
    });

    test('returns correct debit normal balance types', () {
      expect(
        AccountType.debitNormalBalance,
        [AccountType.asset, AccountType.expense],
      );
    });

    test('returns correct credit normal balance types', () {
      expect(
        AccountType.creditNormalBalance,
        [AccountType.liability, AccountType.equity, AccountType.revenue],
      );
    });
  });

  group('AccountCode', () {
    test('creates root code correctly', () {
      final code = AccountCode.root(type: AccountType.asset, systemCode: '001');
      expect(code.typeCode, '1');
      expect(code.systemCode, '001');
      expect(code.subCodes, isEmpty);
      expect(code.value, '1.001');
      expect(code.toString(), '1.001');
      expect(code.isRoot, isTrue);
      expect(code.isSub, isFalse);
    });

    test('creates sub code correctly', () {
      final parent = Account.root(
        name: 'wallet',
        type: AccountType.asset,
        systemCode: '001',
      );
      final code = AccountCode.sub(parent: parent, subCode: '002');
      expect(code.typeCode, '1');
      expect(code.systemCode, '001');
      expect(code.subCodes, ['002']);
      expect(code.value, '1.001.002');
      expect(code.isRoot, isFalse);
      expect(code.isSub, isTrue);
    });

    test('creates nested sub code correctly', () {
      final root = Account.root(
        name: 'wallet',
        type: AccountType.asset,
        systemCode: '001',
      );
      final child1 = Account.sub(
        parent: root,
        name: 'main wallet',
        currentChildrenCount: 0,
      );
      final child2 = Account.sub(
        parent: child1,
        name: 'cash in pocket',
        currentChildrenCount: 0,
      );

      expect(child2.code.typeCode, '1');
      expect(child2.code.systemCode, '001');
      expect(child2.code.subCodes, ['001', '001']);
      expect(child2.code.value, '1.001.001.001');
      expect(child2.code.isRoot, isFalse);
      expect(child2.code.isSub, isTrue);
    });

    test('fromString parses single and nested sub-codes correctly', () {
      final rootCode = AccountCode.fromString('1.001');
      expect(rootCode.typeCode, '1');
      expect(rootCode.systemCode, '001');
      expect(rootCode.subCodes, isEmpty);
      expect(rootCode.isRoot, isTrue);

      final subCode = AccountCode.fromString('1.001.002.003');
      expect(subCode.typeCode, '1');
      expect(subCode.systemCode, '001');
      expect(subCode.subCodes, ['002', '003']);
      expect(subCode.value, '1.001.002.003');
      expect(subCode.isSub, isTrue);
    });

    test('throws AppException on invalid format or segments', () {
      // Less than 2 parts
      expect(
        () => AccountCode.fromString('1'),
        throwsA(isA<AppException>()),
      );
      // Invalid type code
      expect(
        () => AccountCode.fromString('9.001'),
        throwsA(isA<AppException>()),
      );
      // System code length != 3
      expect(
        () => AccountCode.fromString('1.01'),
        throwsA(isA<AppException>()),
      );
      expect(
        () => AccountCode.fromString('1.0001'),
        throwsA(isA<AppException>()),
      );
      // System code non-digits
      expect(
        () => AccountCode.fromString('1.abc'),
        throwsA(isA<AppException>()),
      );
      // Sub code length != 3
      expect(
        () => AccountCode.fromString('1.001.01'),
        throwsA(isA<AppException>()),
      );
      expect(
        () => AccountCode.fromString('1.001.0001'),
        throwsA(isA<AppException>()),
      );
      // Sub code non-digits
      expect(
        () => AccountCode.fromString('1.001.xyz'),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('SystemDefinedAccount', () {
    test('contains expected system default accounts', () {
      expect(SystemDefinedAccount.walletParent.code.value, '1.001');
      expect(SystemDefinedAccount.walletParent.isSystemAccount, isTrue);

      expect(SystemDefinedAccount.incomeParent.code.value, '4.001');
      expect(SystemDefinedAccount.incomeParent.isSystemAccount, isTrue);

      expect(SystemDefinedAccount.expenseParent.code.value, '5.001');
      expect(SystemDefinedAccount.expenseParent.isSystemAccount, isTrue);

      expect(SystemDefinedAccount.feeTransfer.code.value, '5.001.001');
      expect(SystemDefinedAccount.feeTransfer.isSystemAccount, isTrue);
      expect(
        SystemDefinedAccount.feeTransfer.parent,
        SystemDefinedAccount.expenseParent,
      );

      expect(SystemDefinedAccount.accounts, [
        SystemDefinedAccount.walletParent,
        SystemDefinedAccount.incomeParent,
        SystemDefinedAccount.expenseParent,
        SystemDefinedAccount.feeTransfer,
      ]);
    });
  });

  group('Account factories', () {
    test('Account.root creates root account with systemCode', () {
      final account = Account.root(
        name: 'Asset Root',
        type: AccountType.asset,
        systemCode: '001',
      );
      expect(account.name, 'Asset Root');
      expect(account.type, AccountType.asset);
      expect(account.code.value, '1.001');
      expect(account.isSystemAccount, isTrue);
      expect(account.parent, isNull);
    });

    test('Account.sub generates sequential 3-digit sub codes', () {
      final parent = SystemDefinedAccount.walletParent;

      final child1 = Account.sub(
        parent: parent,
        name: 'Wallet 1',
        currentChildrenCount: 0,
      );
      expect(child1.code.value, '1.001.001');
      expect(child1.parent, parent);
      expect(child1.type, parent.type);

      final child10 = Account.sub(
        parent: parent,
        name: 'Wallet 10',
        currentChildrenCount: 9,
      );
      expect(child10.code.value, '1.001.010');

      final child100 = Account.sub(
        parent: parent,
        name: 'Wallet 100',
        currentChildrenCount: 99,
      );
      expect(child100.code.value, '1.001.100');
    });

    test('Account.test creates default test account', () {
      final account = Account.test(AccountType.expense);
      expect(account.type, AccountType.expense);
      expect(account.code.value, '5.001');
      expect(account.name, 'test');
    });
  });

  group('Account.normalBalance', () {
    for (final type in AccountType.creditNormalBalance) {
      test('$type has credit normal balance', () {
        final account = Account.test(type);
        expect(account.normalBalance, BalanceType.credit);
      });
    }

    for (final type in AccountType.debitNormalBalance) {
      test('$type has debit normal balance', () {
        final account = Account.test(type);
        expect(account.normalBalance, BalanceType.debit);
      });
    }
  });

  group('Account.update', () {
    test('updates name when provided', () {
      final account = Account.root(
        name: 'asset',
        type: AccountType.asset,
        systemCode: '001',
      );

      final result = account.update(name: 'updated asset');

      expect(result.name, 'updated asset');
      expect(result.code, account.code);

      final noUpdate = account.update();
      expect(noUpdate, account);
    });
  });
}
