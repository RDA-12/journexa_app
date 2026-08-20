import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/journal.dart';
import 'package:journexa_app/ui/shared/widgets/app_confirmation_dialog.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';
import 'package:journexa_app/ui/wallets/bloc/wallets_bloc.dart';
import 'package:journexa_app/ui/wallets/widgets/delete_wallet_button.dart';
import 'package:journexa_app/ui/wallets/widgets/update_wallet_button.dart';
import 'package:journexa_app/ui/wallets/widgets/wallet_card.dart';
import 'package:journexa_app/ui/wallets/widgets/wallet_form.dart';
import 'package:journexa_app/ui/wallets/widgets/wallets_list.dart';

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
      widget: WalletsList(
        data: data,
        onDeletePressed: onDeletePressed ?? (account) {},
        onUpdatePressed: onUpdatePressed ?? (account, name) {},
      ),
    );
  }

  group('Render', () {
    testWidgets(
      'has correct list of WalletCard',
      (tester) async {
        await pumpWidget(tester);

        final cardFinder = find.byType(WalletCard);
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
          final widget = cards[i].widget as WalletCard;
          expect(widget.accountBalance, accountBalance);
          expect(widget.isDeleting, isDeleting);
          expect(widget.isUpdating, isUpdating);
        }
      },
    );
  });

  group('Interactions', () {
    testWidgets(
      'calls onDeletePressed when WalletCard - DeleteWalletButton '
      'is pressed and user confirmed to delete it',
      (tester) async {
        Account? deletedAccount;
        await pumpWidget(
          tester,
          onDeletePressed: (account) => deletedAccount = account,
        );

        final deleteableData = data.first;
        final deleteableCardFinder = find.byType(WalletCard).first;
        final cardWidget = tester.widget<WalletCard>(
          deleteableCardFinder,
        );
        expect(cardWidget.accountBalance, deleteableData.accountBalance);

        final deleteButtonFinder = find.descendant(
          of: deleteableCardFinder,
          matching: find.byType(DeleteWalletButton),
        );
        final deleteButtonWidget = tester.widget<DeleteWalletButton>(
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
      'calls onUpdatePressed when WalletCard - UpdateWalletButton '
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
        final updatedableCardFinder = find.byType(WalletCard).first;
        final cardWidget = tester.widget<WalletCard>(
          updatedableCardFinder,
        );
        expect(cardWidget.accountBalance, updateableData.accountBalance);

        final updateButtonFinder = find.descendant(
          of: updatedableCardFinder,
          matching: find.byType(UpdateWalletButton),
        );
        final updateButtonWidget = tester.widget<UpdateWalletButton>(
          updateButtonFinder,
        );
        expect(updateButtonWidget.onUpdatePressed, isNotNull);
        expect(updateButtonWidget.isUpdating, isFalse);
        await tester.tap(updateButtonFinder);
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
