import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/ui/home/widgets/mtd_card.dart';
import 'package:journexa_app/ui/shared/l10n/app_localizations.dart';

import '../../util.dart';

final expectedTranslations = {
  'en': {
    'expenseLabel': 'Total Expense',
    'incomeLabel': 'Total Income',
    'netLabel': 'Net Balance',
    'balance': 'Rp 100,000',
  },
  'id': {
    'expenseLabel': 'Total Pengeluaran',
    'incomeLabel': 'Total Pendapatan',
    'netLabel': 'Saldo Bersih',
    'balance': 'Rp 100.000',
  },
};

void main() {
  final balance = Decimal.fromInt(100000);
  final expectedLeadingIcon = {
    MTDCardType.expense: Icons.call_made_rounded,
    MTDCardType.income: Icons.call_received_rounded,
    MTDCardType.net: Icons.balance_rounded,
  };

  Future<void> pumpWidget(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    MTDCardType? type,
  }) {
    return pumpForWidgetTest(
      tester,
      locale: locale,
      widget: MTDCard(type: type ?? MTDCardType.net, data: balance),
    );
  }

  group('Render', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final translations = expectedTranslations[locale.languageCode]!;

      final expectedBalance = translations['balance']!;
      testWidgets('shows correct balance', (tester) async {
        await pumpWidget(tester, locale: locale);

        expect(find.text(expectedBalance), findsOneWidget);
      });

      for (final type in MTDCardType.values) {
        final expectedLabel = translations['${type.name}Label']!;
        testWidgets('shows $expectedLabel label for ${type.name} type '
            'on ${locale.languageCode}', (tester) async {
          await pumpWidget(tester, locale: locale, type: type);

          expect(find.text(expectedLabel), findsOneWidget);
        });
      }
    }

    for (final type in MTDCardType.values) {
      testWidgets('shows correct leading icon for ${type.name}', (
        tester,
      ) async {
        final expectedIcon = expectedLeadingIcon[type]!;

        await pumpWidget(tester, type: type);

        expect(find.widgetWithIcon(CircleAvatar, expectedIcon), findsOneWidget);
      });
    }
  });

  group('a11y', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final translations = expectedTranslations[locale.languageCode]!;

      for (final type in MTDCardType.values) {
        final expectedBalance = translations['balance']!;
        final expectedLabel = translations['${type.name}Label']!;
        testWidgets('has correct semantics for ${type.name} type '
            'on ${locale.languageCode}', (tester) async {
          await pumpWidget(tester, locale: locale, type: type);

          expect(
            find.bySemanticsLabel('$expectedLabel\n$expectedBalance'),
            findsOneWidget,
          );
        });
      }
    }
  });
}
