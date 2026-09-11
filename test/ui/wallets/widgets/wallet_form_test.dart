import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/app_button.dart';
import 'package:journexa_app/ui/shared/widgets/loading_indicator.dart';
import 'package:journexa_app/ui/wallets/widgets/wallet_form.dart';

import '../../util.dart';

final expectedTranslations = {
  'id': {
    'label': 'Nama',
    'button': 'Simpan',
    'required': 'Wajib',
  },
  'en': {
    'label': 'Name',
    'button': 'Save',
    'required': 'Required',
  },
};

void main() {
  Future<void> pumpWidget(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    void Function(String name)? onSavePressed,
    bool isSaving = false,
    Wallet? initialWallet,
  }) async {
    return pumpForWidgetTest(
      tester,
      locale: locale,
      widget: WalletForm(
        initialWallet: initialWallet,
        onSavePressed: onSavePressed,
        isSaving: isSaving,
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
        'when isSaving is True',
        (tester) async {
          await pumpWidget(tester, isSaving: true);

          final buttonFinder = find.byType(FilledButton);
          final buttonWidget = tester.widget<FilledButton>(buttonFinder);
          expect(buttonWidget.enabled, isFalse);

          expect(find.byType(LoadingIndicator), findsOneWidget);
        },
      );

      testWidgets(
        'shows initial account name when provided',
        (tester) async {
          await pumpWidget(
            tester,
            initialWallet: Wallet(
              id: 'id',
              name: 'name',
              account: Account.sub(
                name: 'name',
                parent: SystemDefinedAccount.walletParent,
                currentChildrenCount: 0,
              ),
            ),
          );

          expect(find.text('name'), findsOneWidget);
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
        'invokes onSavePressed when clicks save button',
        (tester) async {
          String? name;
          const expectedName = 'Test';

          await pumpWidget(tester, onSavePressed: (value) => name = value);

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
