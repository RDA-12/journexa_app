import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/ui/add_cash_account/widgets/add_cash_account_form.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/app_button.dart';
import 'package:journexa_app/ui/shared/widgets/loading_indicator.dart';

import '../../util.dart';

final expectedTranslations = {
  'id': {
    'label': 'Nama',
    'button': 'Tambah Kas',
    'required': 'Wajib',
  },
  'en': {
    'label': 'Name',
    'button': 'Add Cash',
    'required': 'Required',
  },
};

void main() {
  Future<void> pumpWidget(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    void Function(String name)? onAddPressed,
    bool isAdding = false,
  }) async {
    return pumpForWidgetTest(
      tester,
      locale: locale,
      widget: AddCashAccountForm(
        onAddPressed: onAddPressed,
        isAdding: isAdding,
      ),
    );
  }

  group(
    'Render',
    () {
      for (final locale in AppLocalizations.supportedLocales) {
        final expectedLocaleTranslated =
            expectedTranslations[locale.languageCode]!;
        final expectedLabel = expectedLocaleTranslated['label']!;
        testWidgets(
          'shows $expectedLabel * label for ${locale.languageCode} ',
          (tester) async {
            await pumpWidget(tester, locale: locale);

            expect(find.text('$expectedLabel *'), findsOneWidget);
          },
        );

        final expectedButton = expectedLocaleTranslated['button']!;
        testWidgets(
          'shows $expectedButton button for ${locale.languageCode}',
          (tester) async {
            await pumpWidget(tester, locale: locale);

            final finder = find.text(expectedButton);
            expect(finder, findsOneWidget);
          },
        );
      }

      testWidgets(
        'has disabled button and shows LoadingIndicator '
        'when isAdding is True',
        (tester) async {
          await pumpWidget(tester, isAdding: true);

          final buttonFinder = find.byType(FilledButton);
          final buttonWidget = tester.widget<FilledButton>(buttonFinder);
          expect(buttonWidget.enabled, isFalse);

          expect(find.byType(LoadingIndicator), findsOneWidget);
        },
      );
    },
  );

  group(
    'Interaction',
    () {
      testWidgets(
        'allows input name',
        (tester) async {
          await pumpWidget(tester);

          final formFieldFinder = find.byType(TextFormField);
          await tester.enterText(formFieldFinder, 'Test');

          expect(find.text('Test'), findsOneWidget);
        },
      );

      testWidgets(
        'invokes onAddPressed when clicks save button',
        (tester) async {
          String? name;
          const expectedName = 'Test';

          await pumpWidget(tester, onAddPressed: (value) => name = value);

          final formFieldFinder = find.byType(TextFormField);
          await tester.enterText(formFieldFinder, expectedName);
          await tester.tap(find.byType(AppButton));

          expect(name, expectedName);
        },
      );
    },
  );

  group('a11y', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final expectedLocaleTranslated =
          expectedTranslations[locale.languageCode]!;
      final expectedLabel = expectedLocaleTranslated['label']!;
      final requiredLabel = expectedLocaleTranslated['required']!;
      testWidgets(
        'shows $expectedLabel, $requiredLabel label semantically for '
        '${locale.languageCode}',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          expect(
            find.bySemanticsLabel('$expectedLabel, $requiredLabel'),
            findsOneWidget,
          );
        },
      );

      final expectedButton = expectedLocaleTranslated['button']!;
      testWidgets(
        'shows $expectedButton button semantically for ${locale.languageCode}',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          final finder = find.bySemanticsLabel(expectedButton);
          expect(finder, findsOneWidget);
        },
      );
    }
  });
}
