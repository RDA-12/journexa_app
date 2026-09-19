import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shell/main_shell_page.dart';
import 'package:journexa_app/ui/shell/widgets/widgets.dart';

import '../util.dart';

final expectedTranslations = {
  'en': {
    'home': 'Home',
    'wallets': 'Wallets',
    'transactions': 'Transactions',
    'settings': 'Settings',
    'income': 'Income',
    'incomeSemantics': 'Add income transaction',
    'expense': 'Expense',
    'expenseSemantics': 'Add expense transaction',
    'transfer': 'Transfer',
    'transferSemantics': 'Add transfer transaction',
  },
  'id': {
    'home': 'Home',
    'wallets': 'Dompet',
    'transactions': 'Transaksi',
    'settings': 'Settings',
    'income': 'Pendapatan',
    'incomeSemantics': 'Tambah transaksi pendapatan',
    'expense': 'Pengeluaran',
    'expenseSemantics': 'Tambah transaksi pengeluaran',
    'transfer': 'Transfer',
    'transferSemantics': 'Tambah transaksi transfer',
  },
};

void main() {
  Future<void> pumpWidget(
    WidgetTester tester, {
    int currentIndex = 0,
    void Function(int)? onDestinationChanged,
    void Function(TransactionType)? onAddTransactionPressed,
    Widget child = const Placeholder(),
    Locale locale = const Locale('en'),
  }) {
    return pumpForWidgetTest(
      tester,
      locale: locale,
      widget: MainShellPage(
        currentIndex: currentIndex,
        onDestinationChanged: onDestinationChanged ?? (_) {},
        onAddTransactionPressed: onAddTransactionPressed ?? (_) {},
        child: child,
      ),
    );
  }

  group('Render', () {
    testWidgets('shows child widget', (tester) async {
      const expectedChild = Placeholder(key: ValueKey('child'));
      await pumpWidget(tester, child: expectedChild);

      expect(find.byKey(const ValueKey('child')), findsOneWidget);
    });

    testWidgets(
      'shows NavigationBar with selectedIndex matching currentIndex',
      (tester) async {
        await pumpWidget(tester, currentIndex: 2);

        final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
        expect(navBar.selectedIndex, 2);
      },
    );

    for (var i = 0; i < 2; i++) {
      testWidgets('shows Fab for index $i', (tester) async {
        await pumpWidget(tester, currentIndex: i);

        expect(find.byType(AppExpandableFab), findsOneWidget);
      });
    }

    for (var i = 2; i < 4; i++) {
      testWidgets('hides Fab for index $i', (tester) async {
        await pumpWidget(tester, currentIndex: i);

        expect(find.byType(AppExpandableFab), findsNothing);
      });
    }

    for (final locale in AppLocalizations.supportedLocales) {
      final translations = expectedTranslations[locale.languageCode]!;
      testWidgets(
        'shows all destinations with icons and labels '
        'for ${locale.languageCode}',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          expect(find.byIcon(Icons.home_rounded), findsOneWidget);
          expect(find.text(translations['home']!), findsOneWidget);

          expect(find.byIcon(Icons.wallet_rounded), findsOneWidget);
          expect(find.text(translations['wallets']!), findsOneWidget);

          expect(find.byIcon(Icons.notes_rounded), findsOneWidget);
          expect(find.text(translations['transactions']!), findsOneWidget);

          expect(find.byIcon(Icons.settings_rounded), findsOneWidget);
          expect(find.text(translations['settings']!), findsOneWidget);
        },
      );

      testWidgets(
        'shows all fab actions with icons and labels '
        'for ${locale.languageCode}',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          await tester.tap(find.byIcon(Icons.add_rounded));

          expect(find.byIcon(Icons.call_received_rounded), findsOneWidget);
          expect(find.text(translations['income']!), findsOneWidget);

          expect(find.byIcon(Icons.call_made_rounded), findsOneWidget);
          expect(find.text(translations['expense']!), findsOneWidget);

          expect(find.byIcon(Icons.swap_vert_rounded), findsOneWidget);
          expect(find.text(translations['transfer']!), findsOneWidget);
        },
      );
    }
  });

  group('Interactions', () {
    for (var i = 0; i < 4; i++) {
      testWidgets(
        'calls onDestinationChanged with index $i when destination $i tapped',
        (tester) async {
          int? selectedIndex;
          await pumpWidget(
            tester,
            onDestinationChanged: (index) => selectedIndex = index,
          );

          await tester.tap(find.byType(NavigationDestination).at(i));
          await tester.pumpAndSettle();

          expect(selectedIndex, i);
        },
      );
    }

    for (final type in TransactionType.values) {
      testWidgets(
        'calls onAddTransactionPressed with $type '
        'when add transaction ${type.name} pressed',
        (tester) async {
          TransactionType? transactionType;
          await pumpWidget(
            tester,
            onAddTransactionPressed: (t) {
              transactionType = t;
            },
          );
          await tester.tap(find.byIcon(Icons.add_rounded));
          await tester.pumpAndSettle();

          final label = expectedTranslations['en']![type.name]!;
          await tester.tap(find.text(label));
          await tester.pumpAndSettle();

          expect(transactionType, type);
        },
      );
    }

    testWidgets('shows correct actions when fab pressed', (tester) async {
      await pumpWidget(tester);

      final finder = find.byIcon(Icons.add_rounded);
      expect(finder, findsOneWidget);
      await tester.tap(finder);
      await tester.pumpAndSettle();

      expect(find.byType(AppFabAction), findsNWidgets(3));
    });
  });

  group('a11y', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final translations = expectedTranslations[locale.languageCode]!;
      testWidgets(
        'has semantic labels for destinations for ${locale.languageCode}',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          expect(
            find.bySemanticsLabel(RegExp('^${translations['home']!}')),
            findsOneWidget,
          );
          expect(
            find.bySemanticsLabel(RegExp('^${translations['wallets']!}')),
            findsOneWidget,
          );
          expect(
            find.bySemanticsLabel(RegExp('^${translations['transactions']!}')),
            findsOneWidget,
          );
          expect(
            find.bySemanticsLabel(RegExp('^${translations['settings']!}')),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'has semantic labels for fab actions for ${locale.languageCode}',
        (tester) async {
          await pumpWidget(tester, locale: locale);
          await tester.tap(find.byIcon(Icons.add_rounded));
          await tester.pumpAndSettle();

          expect(
            find.bySemanticsLabel(translations['incomeSemantics']!),
            findsOneWidget,
          );
          expect(
            find.bySemanticsLabel(translations['expenseSemantics']!),
            findsOneWidget,
          );
          expect(
            find.bySemanticsLabel(translations['transferSemantics']!),
            findsOneWidget,
          );
        },
      );
    }
  });
}
