import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/journal.dart';
import 'package:journexa_app/ui/cash_accounts_list/widgets/cash_account_card.dart';
import 'package:journexa_app/ui/cash_accounts_list/widgets/delete_cash_button.dart';
import 'package:journexa_app/ui/cash_accounts_list/widgets/delete_cash_confirmation_dialog.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';

import '../../util.dart';

final expectedTranslations = {
  'id': {
    'semantics': 'Dompet Hitam, Rp 10.000',
    'balance': 'Rp 10.000',
  },
  'en': {
    'semantics': 'Dompet Hitam, Rp 10,000',
    'balance': 'Rp 10,000',
  },
};

void main() {
  final accountBalance = AccountBalance(
    account: Account(
      code: '10.0001',
      name: 'Dompet Hitam',
      type: AccountType.asset,
    ),
    balance: Decimal.fromInt(10000),
  );

  Future<void> pumpWidget(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    VoidCallback? onDeletePressed,
  }) async {
    return pumpForWidgetTest(
      tester,
      locale: locale,
      widget: CashAccountCard(
        accountBalance: accountBalance,
        onDeletePressed: onDeletePressed ?? () {},
      ),
    );
  }

  group('Render', () {
    testWidgets(
      'shows correct name',
      (tester) async {
        await pumpWidget(tester);

        expect(find.text(accountBalance.account.name), findsOneWidget);
      },
    );

    for (final locale in AppLocalizations.supportedLocales) {
      final expectedBalance =
          expectedTranslations[locale.languageCode]!['balance']!;
      testWidgets(
        'shows correct formatted balance for ${locale.toLanguageTag()}',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          expect(find.text(expectedBalance), findsOneWidget);
        },
      );
    }

    testWidgets('shows correct Initials', (tester) async {
      await pumpWidget(tester);

      expect(find.text('DH'), findsOneWidget);
    });

    testWidgets(
      'shows DeleteCashButton',
      (tester) async {
        await pumpWidget(tester);

        final finder = find.byType(DeleteCashButton);
        expect(finder, findsOneWidget);
        final widget = tester.widget<DeleteCashButton>(finder);
        expect(widget.account, accountBalance.account);
      },
    );
  });

  group('Interactions', () {
    testWidgets(
      'calls onDeletePressed when DeleteCashButton pressed '
      'and user confirmed to delete it',
      (tester) async {
        var isDeleted = false;
        await pumpWidget(
          tester,
          onDeletePressed: () {
            isDeleted = true;
          },
        );

        final finder = find.byType(DeleteCashButton);
        await tester.tap(finder);
        await tester.pump();

        await tester.tap(
          find.descendant(
            of: find.byType(DeleteCashConfirmationDialog),
            matching: find.text('Delete'),
          ),
        );
        await tester.pump();

        expect(isDeleted, isTrue);
      },
    );
  });

  group('a11y', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final expectedSemantics =
          expectedTranslations[locale.toLanguageTag()]!['semantics']!;
      testWidgets(
        'has correct semantics for locale $locale',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          expect(find.bySemanticsLabel(expectedSemantics), findsOneWidget);
        },
      );
    }
  });
}
