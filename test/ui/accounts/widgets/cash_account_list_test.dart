import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/journal.dart';
import 'package:journexa_app/ui/accounts/bloc/cash_accounts_bloc.dart';
import 'package:journexa_app/ui/accounts/widgets/cash_account_card.dart';
import 'package:journexa_app/ui/accounts/widgets/cash_account_form.dart';
import 'package:journexa_app/ui/accounts/widgets/cash_accounts_list.dart';
import 'package:journexa_app/ui/accounts/widgets/delete_cash_button.dart';
import 'package:journexa_app/ui/accounts/widgets/update_cash_button.dart';
import 'package:journexa_app/ui/shared/widgets/app_confirmation_dialog.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';

import '../../util.dart';

void main() {
  final data = List.generate(
    3,
    (idx) {
      final accountBalance = AccountBalance(
        account: Account(
          code: '10.000${idx + 1}',
          name: 'asset $idx',
          type: AccountType.asset,
        ),
        balance: Decimal.fromInt(idx * 1000),
      );
      return AccountBalanceWithState(
        accountBalance: accountBalance,
        isDeleting: !(idx == 0) && idx.isEven,
        isUpdating: !(idx == 0) && idx.isOdd,
      );
    },
  );

  Future<void> pumpWidget(
    WidgetTester tester, {
    void Function(Account)? onDeletePressed,
    void Function(Account, String)? onUpdatePressed,
  }) async {
    return pumpForWidgetTest(
      tester,
      locale: const Locale('en'),
      widget: CashAccountsList(
        data: data,
        onDeletePressed: onDeletePressed ?? (account) {},
        onUpdatePressed: onUpdatePressed ?? (account, name) {},
      ),
    );
  }

  group('Render', () {
    testWidgets(
      'has correct list of CashAccountCard',
      (tester) async {
        await pumpWidget(tester);

        final cardFinder = find.byType(CashAccountCard);
        expect(
          cardFinder,
          findsNWidgets(data.length),
        );

        final cards = cardFinder.evaluate().toList();
        for (var i = 0; i < cards.length; i++) {
          final item = data[i];
          final accountBalance = item.accountBalance;
          final isDeleting = item.isDeleting;
          final isUpdating = item.isUpdating;
          final widget = cards[i].widget as CashAccountCard;
          expect(widget.accountBalance, accountBalance);
          expect(widget.isDeleting, isDeleting);
          expect(widget.isUpdating, isUpdating);
        }
      },
    );
  });

  group('Interactions', () {
    testWidgets(
      'calls onDeletePressed when CashAccountCard - DeleteCashButton '
      'is pressed and user confirmed to delete it',
      (tester) async {
        Account? deletedAccount;
        await pumpWidget(
          tester,
          onDeletePressed: (account) => deletedAccount = account,
        );

        final deleteableData = data.first;
        final deleteableCardFinder = find.byType(CashAccountCard).first;
        final cardWidget = tester.widget<CashAccountCard>(
          deleteableCardFinder,
        );
        expect(cardWidget.accountBalance, deleteableData.accountBalance);

        final deleteButtonFinder = find.descendant(
          of: deleteableCardFinder,
          matching: find.byType(DeleteCashButton),
        );
        final deleteButtonWidget = tester.widget<DeleteCashButton>(
          deleteButtonFinder,
        );
        expect(deleteButtonWidget.onDeletePressed, isNotNull);
        expect(deleteButtonWidget.isDeleting, isFalse);
        await tester.tap(deleteButtonFinder);
        await tester.pump();

        await tester.tap(
          find.descendant(
            of: find.byType(AppConfirmationDialog),
            matching: find.text('Delete'),
          ),
        );
        await tester.pump();

        expect(deletedAccount, deleteableData.accountBalance.account);
      },
    );

    testWidgets(
      'calls onUpdatePressed when CashAccountCard - UpdateCashButton '
      'is pressed and user confirmed to save the update it',
      (tester) async {
        Account? updatedAccount;
        String? updatedName;
        const expectedName = 'new name';
        await pumpWidget(
          tester,
          onUpdatePressed: (account, name) {
            updatedAccount = account;
            updatedName = name;
          },
        );

        final updateableData = data.first;
        final updatedableCardFinder = find.byType(CashAccountCard).first;
        final cardWidget = tester.widget<CashAccountCard>(
          updatedableCardFinder,
        );
        expect(cardWidget.accountBalance, updateableData.accountBalance);

        final updateButtonFinder = find.descendant(
          of: updatedableCardFinder,
          matching: find.byType(UpdateCashButton),
        );
        final updateButtonWidget = tester.widget<UpdateCashButton>(
          updateButtonFinder,
        );
        expect(updateButtonWidget.onUpdatePressed, isNotNull);
        expect(updateButtonWidget.isUpdating, isFalse);
        await tester.tap(updateButtonFinder);
        await tester.pumpAndSettle();

        final formFinder = find.byType(CashAccountForm);
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
            matching: find.byType(AppButton),
          ),
        );
        await tester.pumpAndSettle();

        expect(updatedAccount, updateableData.accountBalance.account);
        expect(updatedName, expectedName);
      },
    );
  });
}
