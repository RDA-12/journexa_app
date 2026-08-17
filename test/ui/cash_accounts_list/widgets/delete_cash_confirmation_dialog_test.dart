import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/ui/cash_accounts_list/widgets/delete_cash_confirmation_dialog.dart';
import 'package:journexa_app/ui/shared/l10n/app_localizations.dart';
import 'package:journexa_app/ui/shared/widgets/app_button.dart';
import 'package:journexa_app/ui/shared/widgets/app_confirmation_dialog.dart';

import '../../util.dart';

final expectedTranslations = {
  'id': {
    'title': 'Hapus dompet hitam?',
    'content':
        'Data yang terikat dengan dompet hitam akan tetap ada. '
        'Tapi, dompet hitam tidak akan bisa digunakan lagi '
        'untuk transaksi selanjutnya',
    'confirmLabel': 'Hapus',
    'cancelLabel': 'Batal',
  },
  'en': {
    'title': 'Delete dompet hitam?',
    'content':
        'Data that related to dompet hitam will still exist. '
        'But, dompet hitam will no longer be able to be used '
        'for future transactions',
    'confirmLabel': 'Delete',
    'cancelLabel': 'Cancel',
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
    ValueChanged<bool>? onDeleted,
  }) {
    return pumpForWidgetTest(
      tester,
      locale: locale,
      widget: DeleteCashConfirmationDialog(
        account: account,
        onDeleted: onDeleted ?? (val) {},
      ),
    );
  }

  group('Render', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final expectedTranslation = expectedTranslations[locale.languageCode]!;
      final expectedTitle = expectedTranslation['title']!;
      final expectedContent = expectedTranslation['content']!;
      final expectedConfirmLabel = expectedTranslation['confirmLabel']!;
      final expectedCancelLabel = expectedTranslation['cancelLabel']!;
      testWidgets(
        'shows correct AppConfirmationDialog for ${locale.languageCode}',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          final finder = find.byType(AppConfirmationDialog);
          expect(finder, findsOneWidget);
          final widget = tester.widget<AppConfirmationDialog>(finder);
          expect(widget.title, expectedTitle);
          expect(widget.content, expectedContent);
          expect(widget.confirmLabel, expectedConfirmLabel);
          expect(widget.cancelLabel, expectedCancelLabel);
        },
      );
    }
  });

  group('Interactions', () {
    testWidgets(
      'calls onDeleted with true when confirm button pressed',
      (tester) async {
        bool? isDeleted;
        const locale = Locale('en');
        final confirmLabel =
            expectedTranslations[locale.languageCode]!['confirmLabel']!;
        await pumpWidget(
          tester,
          onDeleted: (deleted) {
            isDeleted = deleted;
          },
        );

        await tester.tap(find.text(confirmLabel));
        await tester.pump();

        expect(isDeleted, isTrue);
      },
    );

    testWidgets(
      'calls onDeleted with false when cancel button pressed',
      (tester) async {
        bool? isDeleted;
        const locale = Locale('en');
        final cancelLabel =
            expectedTranslations[locale.languageCode]!['cancelLabel']!;
        await pumpWidget(
          tester,
          onDeleted: (deleted) {
            isDeleted = deleted;
          },
        );

        await tester.tap(find.text(cancelLabel));
        await tester.pump();

        expect(isDeleted, isFalse);
      },
    );
  });

  group('DeleteCashConfirmationDialog.show', () {
    const locale = Locale('en');
    final confirmLabel =
        expectedTranslations[locale.languageCode]!['confirmLabel']!;
    final cancelLabel =
        expectedTranslations[locale.languageCode]!['cancelLabel']!;
    Future<void> pumpButtonToShow(
      WidgetTester tester, {
      ValueChanged<bool>? onResult,
    }) {
      return pumpForWidgetTest(
        tester,
        locale: locale,
        widget: Builder(
          builder: (context) {
            return AppButton(
              onPressed: () async {
                final result = await DeleteCashConfirmationDialog.show(
                  context,
                  account: account,
                );
                if (!context.mounted) return;
                onResult?.call(result);
              },
              label: 'show',
            );
          },
        ),
      );
    }

    testWidgets(
      'shows correct AppConfirmationDialog',
      (tester) async {
        const locale = Locale('en');
        final title = expectedTranslations[locale.languageCode]!['title']!;
        final content = expectedTranslations[locale.languageCode]!['content']!;
        final confirmLabel =
            expectedTranslations[locale.languageCode]!['confirmLabel']!;
        final cancelLabel =
            expectedTranslations[locale.languageCode]!['cancelLabel']!;
        await pumpButtonToShow(tester);

        await tester.tap(find.text('show'));
        await tester.pump();

        final finder = find.byType(AppConfirmationDialog);
        expect(finder, findsOneWidget);
        final widget = tester.widget<AppConfirmationDialog>(finder);
        expect(widget.title, title);
        expect(widget.content, content);
        expect(widget.confirmLabel, confirmLabel);
        expect(widget.cancelLabel, cancelLabel);
      },
    );

    group('Interactions', () {
      testWidgets(
        'returns true when confirm button is pressed',
        (tester) async {
          bool? result;
          await pumpButtonToShow(tester, onResult: (v) => result = v);

          await tester.tap(find.text('show'));
          await tester.pump();
          expect(find.byType(AppConfirmationDialog), findsOneWidget);

          await tester.tap(find.text(confirmLabel));
          await tester.pump();

          expect(find.byType(AppConfirmationDialog), findsNothing);
          expect(result, isTrue);
        },
      );

      testWidgets(
        'returns false when cancel button is pressed',
        (tester) async {
          bool? result;
          await pumpButtonToShow(tester, onResult: (v) => result = v);

          await tester.tap(find.text('show'));
          await tester.pump();
          expect(find.byType(AppConfirmationDialog), findsOneWidget);

          await tester.tap(find.text(cancelLabel));
          await tester.pump();

          expect(find.byType(AppConfirmationDialog), findsNothing);
          expect(result, isFalse);
        },
      );
    });
  });
}
