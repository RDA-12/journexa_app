import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/ui/home/widgets/wallet_home_card.dart';
import 'package:journexa_app/ui/shared/l10n/app_localizations.dart';

import '../../util.dart';

const expectedTranslations = {
  'id': {
    'balance': 'Rp 100.000',
  },
  'en': {
    'balance': 'Rp 100,000',
  },
};

void main() {
  const name = 'wallet';
  final balance = Decimal.fromInt(100000);

  Future<void> pumpWidget(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) {
    return pumpForWidgetTest(
      tester,
      locale: locale,
      widget: WalletHomeCard(name: name, balance: balance),
    );
  }

  group('Render', () {
    testWidgets(
      'shows wallet name',
      (tester) async {
        await pumpWidget(tester);

        expect(find.text(name), findsOneWidget);
      },
    );

    for (final locale in AppLocalizations.supportedLocales) {
      testWidgets(
        'shows correct balance for ${locale.languageCode}',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          final balanceText =
              expectedTranslations[locale.languageCode]!['balance']!;

          expect(find.text(balanceText), findsOneWidget);
        },
      );
    }
  });

  group('a11y', () {
    for (final locale in AppLocalizations.supportedLocales) {
      testWidgets(
        'has correct semantics for ${locale.languageCode}',
        (tester) async {
          await pumpWidget(tester, locale: locale);
          final expectedBalance =
              expectedTranslations[locale.languageCode]!['balance']!;

          expect(
            find.bySemanticsLabel('$name\n$expectedBalance'),
            findsOneWidget,
          );
        },
      );
    }
  });
}
