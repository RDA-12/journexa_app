import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/ui/login/widgets/login_header.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';

import '../../util.dart';

final expectedTranslations = {
  'id': {
    'tagline': 'Partner finansial pribadi Anda',
  },
  'en': {
    'tagline': 'Your personal financial partner',
  },
};

void main() {
  Future<void> pumpWidget(WidgetTester tester, {required Locale locale}) {
    return pumpForWidgetTest(
      tester,
      locale: locale,
      widget: const LoginHeader(),
    );
  }

  Future<void> pumpLargeFontWidget(
    WidgetTester tester, {
    required Locale locale,
  }) {
    return pumpForLargeFontTest(
      tester,
      locale: locale,
      widget: const LoginHeader(),
    );
  }

  group('Render', () {
    for (final locale in AppLocalizations.supportedLocales) {
      testWidgets(
        'shows "Journexa" for $locale',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          expect(find.text('Journexa'), findsOneWidget);
        },
      );
      final expectedTagline =
          expectedTranslations[locale.languageCode]!['tagline']!;

      testWidgets(
        'shows $expectedTagline for $locale',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          expect(find.text(expectedTagline), findsOneWidget);
        },
      );
    }
  });

  group('a11y', () {
    for (final locale in AppLocalizations.supportedLocales) {
      testWidgets(
        'has "Journexa" semantically for $locale',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          expect(find.bySemanticsLabel('Journexa'), findsOneWidget);
        },
      );

      testWidgets(
        'no overflow error on "Journexa" for $locale '
        'when using large text scaler',
        (tester) async {
          await pumpLargeFontWidget(tester, locale: locale);

          expect(tester.takeException(), isNull);
        },
      );

      final expectedTagline =
          expectedTranslations[locale.languageCode]!['tagline']!;
      testWidgets(
        'has $expectedTagline semantically for $locale',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          expect(find.bySemanticsLabel(expectedTagline), findsOneWidget);
        },
      );

      testWidgets(
        'no overflow error on $expectedTagline for $locale '
        'when using large text scaler',
        (tester) async {
          await pumpLargeFontWidget(tester, locale: locale);

          expect(tester.takeException(), isNull);
        },
      );
    }
  });
}
