import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/ui/shared/l10n/app_localizations.dart';
import 'package:journexa_app/ui/wallets/widgets/update_wallet_button.dart';
import 'package:journexa_app/ui/wallets/widgets/wallet_form.dart';

import '../../util.dart';

final expectedTranslations = {
  'id': {
    'label': 'Perbarui',
    'semanticsLabel': 'Perbarui dompet hitam',
    'deletingLabel': 'Memperbarui',
    'deletingSemanticsLabel': 'Memperbarui dompet hitam',
  },
  'en': {
    'label': 'Update',
    'semanticsLabel': 'Update dompet hitam',
    'deletingLabel': 'Updating',
    'deletingSemanticsLabel': 'Updating dompet hitam',
  },
};

void main() {
  final account = Account(
    code: '10.0001',
    name: 'dompet hitam',
    type: AccountType.asset,
  );

  Future<void> pumpWidget(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    void Function(String name)? onUpdatePressed,
    bool isUpdating = false,
  }) {
    return pumpForWidgetTest(
      tester,
      locale: locale,
      widget: UpdateWalletButton(
        account: account,
        isUpdating: isUpdating,
        onUpdatePressed: onUpdatePressed,
      ),
    );
  }

  group('Render', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final expectedLabel =
          expectedTranslations[locale.languageCode]!['label']!;
      testWidgets(
        'shows $expectedLabel label for ${locale.languageCode}',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          expect(find.text(expectedLabel), findsOneWidget);
        },
      );

      final expectedDeletingLabel =
          expectedTranslations[locale.languageCode]!['deletingLabel']!;
      testWidgets(
        'shows $expectedDeletingLabel label for ${locale.languageCode} '
        'when isUpdating true',
        (tester) async {
          await pumpWidget(tester, locale: locale, isUpdating: true);

          expect(find.text(expectedDeletingLabel), findsOneWidget);
        },
      );
    }

    testWidgets(
      'disabled when isUpdating true',
      (tester) async {
        await pumpWidget(tester, isUpdating: true);

        final finder = find.byType(TextButton);
        final widget = tester.widget<TextButton>(finder);
        expect(widget.enabled, isFalse);
      },
    );
  });

  group('Interactions', () {
    testWidgets(
      'shows WalletForm with correct Account '
      'when pressed',
      (tester) async {
        await pumpWidget(tester, onUpdatePressed: (_) {});

        await tester.tap(find.byType(UpdateWalletButton));
        await tester.pumpAndSettle();

        final finder = find.byType(WalletForm);
        expect(finder, findsOneWidget);
        final widget = tester.widget<WalletForm>(finder);
        expect(widget.initialAccount, account);
      },
    );

    testWidgets(
      'calls onUpdatePressed when save on WalletForm pressed',
      (tester) async {
        const expectedName = 'new name';
        String? newName;
        await pumpWidget(
          tester,
          onUpdatePressed: (value) {
            newName = value;
          },
        );

        await tester.tap(find.byType(UpdateWalletButton));
        await tester.pumpAndSettle();

        final formFinder = find.byType(WalletForm);
        expect(formFinder, findsOneWidget);

        await tester.enterText(
          find.descendant(
            of: formFinder,
            matching: find.byType(TextFormField),
          ),
          expectedName,
        );
        await tester.tap(
          find.descendant(
            of: formFinder,
            matching: find.text('Save'),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(WalletForm), findsNothing);
        expect(newName, expectedName);
      },
    );
  });

  group('a11y', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final expectedSemanticsLabel =
          expectedTranslations[locale.languageCode]!['semanticsLabel']!;
      testWidgets(
        'has $expectedSemanticsLabel semantically '
        'for ${locale.languageCode}',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          expect(
            find.bySemanticsLabel(expectedSemanticsLabel),
            findsOneWidget,
          );
        },
      );

      final expectedDeletingSemanticsLabel =
          expectedTranslations[locale.languageCode]!['deletingSemanticsLabel']!;
      testWidgets(
        'has $expectedDeletingSemanticsLabel label semantically '
        'for ${locale.languageCode} when isUpdating true',
        (tester) async {
          await pumpWidget(tester, locale: locale, isUpdating: true);

          expect(
            find.bySemanticsLabel(expectedDeletingSemanticsLabel),
            findsOneWidget,
          );
        },
      );
    }
  });
}
