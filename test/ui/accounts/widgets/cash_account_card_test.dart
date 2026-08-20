import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/journal.dart';
import 'package:journexa_app/ui/accounts/widgets/cash_account_card.dart';
import 'package:journexa_app/ui/accounts/widgets/cash_account_form.dart';
import 'package:journexa_app/ui/accounts/widgets/delete_cash_button.dart';
import 'package:journexa_app/ui/accounts/widgets/update_cash_button.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/app_confirmation_dialog.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';

import '../../util.dart';

final expectedTranslations = {
  'id': {
    'semantics': 'Dompet Hitam, Saldo Rp 10.000',
    'balance': 'Rp 10.000',
  },
  'en': {
    'semantics': 'Dompet Hitam, Balance Rp 10,000',
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
    bool isDeleting = false,
    VoidCallback? onDeletePressed,
    bool isUpdating = false,
    void Function(String)? onUpdatePressed,
  }) async {
    return pumpForWidgetTest(
      tester,
      locale: locale,
      widget: CashAccountCard(
        accountBalance: accountBalance,
        isDeleting: isDeleting,
        onDeletePressed: onDeletePressed ?? () {},
        isUpdating: isUpdating,
        onUpdatePressed: onUpdatePressed ?? (v) {},
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

    testWidgets(
      'shows UpdateCashButton',
      (tester) async {
        await pumpWidget(tester);

        final finder = find.byType(UpdateCashButton);
        expect(finder, findsOneWidget);
        final widget = tester.widget<UpdateCashButton>(finder);
        expect(widget.account, accountBalance.account);
      },
    );

    testWidgets(
      'disabled DeleteCashButton when isDeleting is true',
      (tester) async {
        await pumpWidget(tester, isDeleting: true);

        final finder = find.byType(DeleteCashButton);
        expect(finder, findsOneWidget);
        final buttonFinder = find.descendant(
          of: finder,
          matching: find.byType(AppButton),
        );
        final widget = tester.widget<AppButton>(buttonFinder);
        expect(widget.onPressed, isNull);
      },
    );

    testWidgets(
      'disabled DeleteCashButton when isUpdating is true',
      (tester) async {
        await pumpWidget(tester, isUpdating: true);

        final finder = find.byType(DeleteCashButton);
        expect(finder, findsOneWidget);
        final buttonFinder = find.descendant(
          of: finder,
          matching: find.byType(AppButton),
        );
        final widget = tester.widget<AppButton>(buttonFinder);
        expect(widget.onPressed, isNull);
      },
    );

    testWidgets(
      'disabled UpdateCashButton when isDeleting is true',
      (tester) async {
        await pumpWidget(tester, isDeleting: true);

        final finder = find.byType(UpdateCashButton);
        expect(finder, findsOneWidget);
        final buttonFinder = find.descendant(
          of: finder,
          matching: find.byType(AppButton),
        );
        final widget = tester.widget<AppButton>(buttonFinder);
        expect(widget.onPressed, isNull);
      },
    );

    testWidgets(
      'disabled UpdateCashButton when isUpdating is true',
      (tester) async {
        await pumpWidget(tester, isUpdating: true);

        final finder = find.byType(UpdateCashButton);
        expect(finder, findsOneWidget);
        final buttonFinder = find.descendant(
          of: finder,
          matching: find.byType(AppButton),
        );
        final widget = tester.widget<AppButton>(buttonFinder);
        expect(widget.onPressed, isNull);
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
            of: find.byType(AppConfirmationDialog),
            matching: find.text('Delete'),
          ),
        );
        await tester.pump();

        expect(isDeleted, isTrue);
      },
    );

    testWidgets(
      'calls onUpdatePressed with correct name '
      'when UpdateCashButton pressed and user save the updated data',
      (tester) async {
        String? newName;
        const expectedName = 'name';

        await pumpWidget(
          tester,
          onUpdatePressed: (name) {
            newName = name;
          },
        );

        await tester.tap(find.byType(UpdateCashButton));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField), expectedName);
        await tester.tap(
          find.descendant(
            of: find.byType(CashAccountForm),
            matching: find.byType(AppButton),
          ),
        );
        await tester.pumpAndSettle();

        expect(newName, expectedName);
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
