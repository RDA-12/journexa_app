import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/ui/shared/l10n/app_localizations.dart';
import 'package:journexa_app/ui/shared/widgets/app_dialog.dart';
import 'package:journexa_app/ui/wallets/widgets/delete_wallet_button.dart';

import '../../util.dart';

final expectedTranslations = {
  'id': {
    'label': 'Hapus',
    'semanticsLabel': 'Hapus dompet hitam',
    'deletingLabel': 'Menghapus',
    'deletingSemanticsLabel': 'Menghapus dompet hitam',
  },
  'en': {
    'label': 'Delete',
    'semanticsLabel': 'Delete dompet hitam',
    'deletingLabel': 'Deleting',
    'deletingSemanticsLabel': 'Deleting dompet hitam',
  },
};

void main() {
  final wallet = Wallet(
    id: 'id',
    name: 'dompet hitam',
    account: Account.sub(
      parent: SystemDefinedAccount.walletParent,
      name: 'dompet hitam',
      currentChildrenCount: 0,
    ),
  );

  Future<void> pumpWidget(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    VoidCallback? onDeletePressed,
    bool isDeleting = false,
  }) {
    return pumpForWidgetTest(
      tester,
      locale: locale,
      widget: DeleteWalletButton(
        wallet: wallet,
        isDeleting: isDeleting,
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

      final expectedDeletingLabel =
          expectedTranslations[locale.languageCode]!['deletingLabel']!;
      testWidgets(
        'shows $expectedDeletingLabel label for ${locale.languageCode} '
        'when isDeleting true',
        (tester) async {
          await pumpWidget(tester, locale: locale, isDeleting: true);

          expect(find.text(expectedDeletingLabel), findsOneWidget);
        },
      );
    }

    testWidgets(
      'disabled when isDeleting true',
      (tester) async {
        await pumpWidget(tester, isDeleting: true);

        final finder = find.byType(TextButton);
        final widget = tester.widget<TextButton>(finder);
        expect(widget.enabled, isFalse);
      },
    );

    testWidgets(
      'disabled when onDeletePressed is null',
      (tester) async {
        await pumpWidget(tester);

        final finder = find.byType(TextButton);
        final widget = tester.widget<TextButton>(finder);
        expect(widget.enabled, isFalse);
      },
    );
  });

  group('Interactions', () {
    testWidgets(
      'shows AppDialog when pressed',
      (tester) async {
        await pumpWidget(tester, onDeletePressed: () {});

        await tester.tap(find.byType(DeleteWalletButton));
        await tester.pump();

        expect(find.byType(AppDialog), findsOneWidget);
      },
    );

    testWidgets(
      'calls onDeletePressed when AppDialog confirmed',
      (tester) async {
        var deleted = false;
        await pumpWidget(
          tester,
          onDeletePressed: () {
            deleted = true;
          },
        );

        await tester.tap(find.byType(DeleteWalletButton));
        await tester.pump();

        expect(find.byType(AppDialog), findsOneWidget);

        await tester.tap(
          find.descendant(
            of: find.byType(AppDialog),
            matching: find.text('Delete'),
          ),
        );
        await tester.pump();

        expect(find.byType(AppDialog), findsNothing);
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

      final expectedDeletingSemanticsLabel =
          expectedTranslations[locale.languageCode]!['deletingSemanticsLabel']!;
      testWidgets(
        'has $expectedDeletingSemanticsLabel label semantically '
        'for ${locale.languageCode} when isDeleting true',
        (tester) async {
          await pumpWidget(tester, locale: locale, isDeleting: true);

          expect(
            find.bySemanticsLabel(expectedDeletingSemanticsLabel),
            findsOneWidget,
          );
        },
      );
    }
  });
}
