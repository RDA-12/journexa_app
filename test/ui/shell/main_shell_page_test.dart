import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shell/main_shell_page.dart';

import '../util.dart';

final expectedTranslations = {
  'en': {
    'home': 'Home',
    'wallets': 'Wallets',
    'transactions': 'Transactions',
    'settings': 'Settings',
  },
  'id': {
    'home': 'Home',
    'wallets': 'Dompet',
    'transactions': 'Transaksi',
    'settings': 'Settings',
  },
};

void main() {
  Future<void> pumpWidget(
    WidgetTester tester, {
    int currentIndex = 0,
    void Function(int)? onDestinationChanged,
    Widget child = const Placeholder(),
    Locale locale = const Locale('en'),
  }) {
    return pumpForWidgetTest(
      tester,
      locale: locale,
      widget: MainShellPage(
        currentIndex: currentIndex,
        onDestinationChanged: onDestinationChanged ?? (_) {},
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
  });

  group('a11y', () {
    testWidgets('follows a11y guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpWidget(tester);

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      handle.dispose();
    });

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
    }
  });
}
