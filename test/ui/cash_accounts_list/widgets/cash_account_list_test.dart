import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/journal.dart';
import 'package:journexa_app/ui/cash_accounts_list/bloc/cash_accounts_bloc.dart';
import 'package:journexa_app/ui/cash_accounts_list/widgets/cash_account_card.dart';
import 'package:journexa_app/ui/cash_accounts_list/widgets/cash_accounts_list.dart';
import 'package:journexa_app/ui/cash_accounts_list/widgets/delete_cash_button.dart';
import 'package:journexa_app/ui/shared/widgets/app_confirmation_dialog.dart';

import '../../util.dart';

void main() {
  final data = List.generate(
    2,
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
        isDeleting: idx.isEven,
      );
    },
  );

  Future<void> pumpWidget(
    WidgetTester tester, {
    void Function(Account)? onDeletePressed,
  }) async {
    return pumpForWidgetTest(
      tester,
      locale: const Locale('en'),
      widget: CashAccountsList(
        data: data,
        onDeletePressed: onDeletePressed ?? (account) {},
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
          final widget = cards[i].widget as CashAccountCard;
          expect(widget.accountBalance, accountBalance);
          expect(widget.isDeleting, isDeleting);
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

        final deleteableData = data.last;
        final deleteableCardFinder = find.byType(CashAccountCard).last;
        final cardWidget = tester.widget<CashAccountCard>(
          deleteableCardFinder,
        );
        expect(cardWidget.accountBalance, deleteableData.accountBalance);

        final deleteButtonFinder = find.descendant(
          of: deleteableCardFinder,
          matching: find.byType(DeleteCashButton),
        );
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
  });
}
