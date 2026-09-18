import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:journexa_app/ui/settings/settings_page.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';

import '../util.dart';

final expectedTranslations = {
  'en': {
    'incomeCategoryLabel': 'Income category',
    'incomeCategorySemantics': 'See all income categories',
    'expenseCategoryLabel': 'Expense category',
    'expenseCategorySemantics': 'See all expense categories',
  },
  'id': {
    'incomeCategoryLabel': 'Kategori pendapatan',
    'incomeCategorySemantics': 'Lihat semua kategori pendapatan',
    'expenseCategoryLabel': 'Kategori pengeluaran',
    'expenseCategorySemantics': 'Lihat semua kategori pengeluaran',
  },
};

void main() {
  Future<void> pumpWidget(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    List<RouteBase> nextRoutes = const [],
  }) {
    return pumpForPageTest(
      tester,
      initialLocation: '/settings',
      routes: [
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),
        ...nextRoutes,
      ],
      locale: locale,
    );
  }

  group('Render', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final translations = expectedTranslations[locale.languageCode]!;

      final incomeCategoryLabel = translations['incomeCategoryLabel']!;
      testWidgets(
        'shows $incomeCategoryLabel tile for ${locale.languageCode}',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          expect(find.text(incomeCategoryLabel), findsOneWidget);
        },
      );

      final expenseCategoryLabel = translations['expenseCategoryLabel']!;
      testWidgets(
        'shows $expenseCategoryLabel tile for ${locale.languageCode}',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          expect(find.text(expenseCategoryLabel), findsOneWidget);
        },
      );
    }
  });

  group('Interactions', () {
    testWidgets(
      'go to /income-categories page '
      'when income category tile pressed',
      (tester) async {
        const expectedWidget = Placeholder(
          key: ValueKey('income-category'),
        );
        await pumpWidget(
          tester,
          nextRoutes: [
            GoRoute(
              path: '/income-categories',
              builder: (context, state) => expectedWidget,
            ),
          ],
        );
        expect(find.byWidget(expectedWidget), findsNothing);

        await tester.tap(find.text('Income category'));
        await tester.pumpAndSettle();

        expect(find.byWidget(expectedWidget), findsOneWidget);
      },
    );
    testWidgets(
      'go to /expense-categories page '
      'when income category tile pressed',
      (tester) async {
        const expectedWidget = Placeholder(
          key: ValueKey('expense-category'),
        );
        await pumpWidget(
          tester,
          nextRoutes: [
            GoRoute(
              path: '/expense-categories',
              builder: (context, state) => expectedWidget,
            ),
          ],
        );
        expect(find.byWidget(expectedWidget), findsNothing);

        await tester.tap(find.text('Expense category'));
        await tester.pumpAndSettle();

        expect(find.byWidget(expectedWidget), findsOneWidget);
      },
    );
  });

  group('a11y', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final translations = expectedTranslations[locale.languageCode]!;

      final incomeCategorySemantics = translations['incomeCategorySemantics']!;
      testWidgets(
        'has $incomeCategorySemantics semantically for income category tile '
        'for ${locale.languageCode}',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          expect(
            find.bySemanticsLabel(incomeCategorySemantics),
            findsOneWidget,
          );
        },
      );

      final expenseCategorySemantics =
          translations['expenseCategorySemantics']!;
      testWidgets(
        'has $expenseCategorySemantics semantically for expense category tile '
        'for ${locale.languageCode}',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          expect(
            find.bySemanticsLabel(expenseCategorySemantics),
            findsOneWidget,
          );
        },
      );
    }
  });
}
