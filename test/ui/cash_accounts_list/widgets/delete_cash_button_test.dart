import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/ui/cash_accounts_list/widgets/delete_cash_button.dart';
import 'package:journexa_app/ui/cash_accounts_list/widgets/delete_cash_confirmation_dialog.dart';
import 'package:journexa_app/ui/shared/l10n/app_localizations.dart';

import '../../util.dart';

final expectedTranslations = {
  'id': {
    'label': 'Hapus',
    'semanticsLabel': 'Hapus dompet hitam',
  },
  'en': {
    'label': 'Delete',
    'semanticsLabel': 'Delete dompet hitam',
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
    VoidCallback? onDeletePressed,
  }) {
    return pumpForWidgetTest(
      tester,
      locale: locale,
      widget: DeleteCashButton(
        account: account,
        onDeletePressed: onDeletePressed,
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
    }

    testWidgets(
      'shows delete icon',
      (tester) async {
        await pumpWidget(tester);

        expect(find.byIcon(Icons.delete_rounded), findsOneWidget);
      },
    );
  });

  group('Interactions', () {
    testWidgets(
      'shows DeleteCashConfirmationDialog when pressed',
      (tester) async {
        await pumpWidget(tester);

        await tester.tap(find.byType(DeleteCashButton));
        await tester.pump();

        expect(find.byType(DeleteCashConfirmationDialog), findsOneWidget);
      },
    );

    testWidgets(
      'calls onDeletePressed when DeleteCashConfirmationDialog confirmed',
      (tester) async {
        var deleted = false;
        await pumpWidget(
          tester,
          onDeletePressed: () {
            deleted = true;
          },
        );

        await tester.tap(find.byType(DeleteCashButton));
        await tester.pump();

        expect(find.byType(DeleteCashConfirmationDialog), findsOneWidget);

        await tester.tap(
          find.descendant(
            of: find.byType(DeleteCashConfirmationDialog),
            matching: find.text('Delete'),
          ),
        );
        await tester.pump();

        expect(find.byType(DeleteCashConfirmationDialog), findsNothing);
        expect(deleted, isTrue);
      },
    );
  });

  group('a11y', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final expectedSemanticsLabel =
          expectedTranslations[locale.languageCode]!['semanticsLabel']!;
      testWidgets(
        'has $expectedSemanticsLabel tooltip '
        'for ${locale.languageCode}',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          expect(
            find.bySemanticsLabel(expectedSemanticsLabel),
            findsOneWidget,
          );
        },
      );
    }
  });
}
