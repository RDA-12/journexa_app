import 'dart:ui';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/app_logo.dart';

import '../../util.dart';

const expectedTranslations = {
  'id': {'label': 'Logo Journexa'},
  'en': {'label': 'Journexa logo'},
};

void main() {
  Future<void> pumpWidget(
    WidgetTester tester, {
    double? size,
    Locale locale = const Locale('en'),
    String? semanticsLabel,
    bool addSemanticsLabel = false,
  }) {
    return pumpForWidgetTest(
      tester,
      locale: locale,
      widget: AppLogo(
        size: size,
        semanticsLabel: semanticsLabel,
        addSemanticsLabel: addSemanticsLabel,
      ),
    );
  }

  group('Render', () {
    testWidgets('shows correct logo', (tester) async {
      await pumpWidget(tester);

      final logo = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(
        logo.bytesLoader,
        isA<SvgAssetLoader>().having(
          (e) => e.assetName,
          'assetName',
          'assets/logo/logo.svg',
        ),
      );
    });

    testWidgets('has 24 default size', (tester) async {
      await pumpWidget(tester);

      final logo = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(logo.width, 24);
      expect(logo.height, 24);
    });

    testWidgets('has custom size', (tester) async {
      const customSize = 128.0;
      await pumpWidget(tester, size: customSize);

      final logo = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(logo.width, customSize);
      expect(logo.height, customSize);
    });
  });

  group('a11y', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final expectedLabel =
          expectedTranslations[locale.languageCode]!['label']!;
      testWidgets(
        'has $expectedLabel semantically by default for ${locale.languageCode} '
        'when addSemanticsLabel set to true',
        (tester) async {
          await pumpWidget(tester, locale: locale, addSemanticsLabel: true);

          expect(find.bySemanticsLabel(expectedLabel), findsOneWidget);
        },
      );
    }

    testWidgets('has semanticsLabel semantically when provided', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        semanticsLabel: 'semantics',
        addSemanticsLabel: true,
      );

      expect(find.bySemanticsLabel('semantics'), findsOneWidget);
    });
  });
}
