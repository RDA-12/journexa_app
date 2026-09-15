import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/ui/shared/l10n/app_localizations.dart';
import 'package:journexa_app/ui/shared/widgets/app_logo.dart';
import 'package:journexa_app/ui/splash/widgets/splash_box.dart';

import '../../util.dart';

const expectedTranslations = {
  'id': {'label': 'Membuka aplidompeti Journexa'},
  'en': {'label': 'Opening Journexa app'},
};

void main() {
  Future<void> pumpWidget(
    WidgetTester tester, {
    Locale locale = const Locale('id'),
  }) {
    return pumpForWidgetTest(tester, locale: locale, widget: const SplashBox());
  }

  group('Render', () {
    testWidgets('shows AppLogo', (tester) async {
      await pumpWidget(tester);

      expect(find.byType(AppLogo), findsOneWidget);
    });
  });

  group('a11y', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final expectedLabel =
          expectedTranslations[locale.languageCode]!['label']!;
      testWidgets(
        'has $expectedLabel semantically for ${locale.languageCode}',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          expect(find.bySemanticsLabel(expectedLabel), findsOneWidget);
        },
      );
    }
  });
}
