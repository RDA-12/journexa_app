import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/expense_category.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/models/transaction_ui_model.dart';
import 'package:journexa_app/ui/transactions/widgets/transaction_card.dart';

import '../../util.dart';

final expectedTranslations = {
  'id': {
    'balance': 'Rp 50.000',
    'incomeSubtitle': 'ke Main Wallet',
    'expenseSubtitle': 'dari Main Wallet',
    'transferSubtitle': 'dari Source Wallet',
    'incomeSemantics':
        'Pendapatan Rp 50.000 ke Main Wallet '
        'untuk Salary pada 05 September 2026',
    'expenseSemantics':
        'Pengeluaran Rp 50.000 dari Main Wallet '
        'untuk Groceries pada 05 September 2026',
    'transferSemantics':
        'Transfer Rp 50.000 ke Dest Wallet '
        'dari Source Wallet pada 05 September 2026',
  },
  'en': {
    'balance': 'Rp 50,000',
    'incomeSubtitle': 'to Main Wallet',
    'expenseSubtitle': 'from Main Wallet',
    'transferSubtitle': 'from Source Wallet',
    'incomeSemantics':
        'Income Rp 50,000 to Main Wallet '
        'for Salary at 05 September 2026',
    'expenseSemantics':
        'Expense Rp 50,000 from Main Wallet '
        'for Groceries at 05 September 2026',
    'transferSemantics':
        'Transfer Rp 50,000 to Dest Wallet '
        'from Source Wallet at 05 September 2026',
  },
};

void main() {
  final date = DateTime(2026, 9, 5, 12);
  final amount = Decimal.fromInt(50000);

  final wallet = Wallet.test().copyWith(
    name: 'Main Wallet',
    account: Account.test().copyWith(
      name: 'Main Wallet',
      parent: SystemDefinedAccount.walletParent,
    ),
  );

  final sourceWallet = Wallet.test().copyWith(
    id: 'source-id',
    name: 'Source Wallet',
    account: Account.test().copyWith(
      name: 'Source Wallet',
      parent: SystemDefinedAccount.walletParent,
    ),
  );

  final destinationWallet = Wallet.test().copyWith(
    id: 'dest-id',
    name: 'Dest Wallet',
    account: Account.test().copyWith(
      name: 'Dest Wallet',
      parent: SystemDefinedAccount.walletParent,
    ),
  );

  final incomeCategory = IncomeCategory.test().copyWith(
    name: 'Salary',
    account: Account.test(AccountType.revenue).copyWith(
      name: 'Salary',
      parent: SystemDefinedAccount.incomeParent,
    ),
  );

  final expenseCategory = ExpenseCategory.test().copyWith(
    name: 'Groceries',
    account: Account.test(AccountType.expense).copyWith(
      name: 'Groceries',
      parent: SystemDefinedAccount.expenseParent,
    ),
  );

  final incomeData = TransactionUIModel.income(
    id: 'income-id',
    wallet: wallet,
    category: incomeCategory,
    amount: amount,
    date: date,
  );

  final expenseData = TransactionUIModel.expense(
    id: 'expense-id',
    wallet: wallet,
    category: expenseCategory,
    amount: amount,
    date: date,
  );

  final transferData = TransactionUIModel.transfer(
    id: 'transfer-id',
    sourceWallet: sourceWallet,
    destinationWallet: destinationWallet,
    amount: amount,
    fee: Decimal.zero,
    date: date,
  );

  Future<void> pumpWidget(
    WidgetTester tester, {
    required TransactionUIModel data,
    Locale locale = const Locale('en'),
  }) {
    return pumpForWidgetTest(
      tester,
      locale: locale,
      widget: TransactionCard(data: data),
    );
  }

  group('Render', () {
    group('Income', () {
      testWidgets('shows correct category and date', (tester) async {
        await pumpWidget(tester, data: incomeData);

        expect(find.text('Salary'), findsOneWidget);
        expect(find.text('05/09/2026'), findsOneWidget);
      });

      for (final locale in AppLocalizations.supportedLocales) {
        final expected = expectedTranslations[locale.languageCode]!;
        testWidgets(
          'shows correct formatted balance and subtitle '
          'for ${locale.languageCode}',
          (tester) async {
            await pumpWidget(tester, data: incomeData, locale: locale);

            expect(find.text(expected['balance']!), findsOneWidget);
            expect(find.text(expected['incomeSubtitle']!), findsOneWidget);
          },
        );
      }
    });

    group('Expense', () {
      testWidgets('shows correct category and date', (tester) async {
        await pumpWidget(tester, data: expenseData);

        expect(find.text('Groceries'), findsOneWidget);
        expect(find.text('05/09/2026'), findsOneWidget);
      });

      for (final locale in AppLocalizations.supportedLocales) {
        final expected = expectedTranslations[locale.languageCode]!;
        testWidgets(
          'shows correct formatted balance and subtitle '
          'for ${locale.languageCode}',
          (tester) async {
            await pumpWidget(tester, data: expenseData, locale: locale);

            expect(find.text(expected['balance']!), findsOneWidget);
            expect(find.text(expected['expenseSubtitle']!), findsOneWidget);
          },
        );
      }
    });

    group('Transfer', () {
      testWidgets('shows correct destination wallet and date', (tester) async {
        await pumpWidget(tester, data: transferData);

        expect(find.text('Dest Wallet'), findsOneWidget);
        expect(find.text('05/09/2026'), findsOneWidget);
      });

      for (final locale in AppLocalizations.supportedLocales) {
        final expected = expectedTranslations[locale.languageCode]!;
        testWidgets(
          'shows correct formatted balance and subtitle '
          'for ${locale.languageCode}',
          (tester) async {
            await pumpWidget(tester, data: transferData, locale: locale);

            expect(find.text(expected['balance']!), findsOneWidget);
            expect(find.text(expected['transferSubtitle']!), findsOneWidget);
          },
        );
      }
    });
  });

  group('a11y', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final expected = expectedTranslations[locale.languageCode]!;

      testWidgets('has correct income semantics for $locale', (tester) async {
        await pumpWidget(tester, data: incomeData, locale: locale);

        expect(
          find.bySemanticsLabel(expected['incomeSemantics']!),
          findsOneWidget,
        );
      });

      testWidgets('has correct expense semantics for $locale', (tester) async {
        await pumpWidget(tester, data: expenseData, locale: locale);

        expect(
          find.bySemanticsLabel(expected['expenseSemantics']!),
          findsOneWidget,
        );
      });

      testWidgets('has correct transfer semantics for $locale', (tester) async {
        await pumpWidget(tester, data: transferData, locale: locale);

        expect(
          find.bySemanticsLabel(expected['transferSemantics']!),
          findsOneWidget,
        );
      });
    }
  });
}
