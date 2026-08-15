import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/journal.dart';
import 'package:journexa_app/ui/cash_accounts_list/widgets/cash_account_card.dart';
import 'package:journexa_app/ui/cash_accounts_list/widgets/cash_accounts_list.dart';

import '../../util.dart';

void main() {
  final cashBalances = List.generate(
    5,
    (idx) => AccountBalance(
      account: Account(
        code: '10.000${idx + 1}',
        name: 'asset $idx',
        type: AccountType.asset,
      ),
      balance: Decimal.fromInt(idx * 1000),
    ),
  );

  Future<void> pumpWidget(WidgetTester tester) async {
    return pumpForWidgetTest(
      tester,
      locale: const Locale('en'),
      widget: CashAccountsList(
        accountBalances: cashBalances,
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
          findsNWidgets(cashBalances.length),
        );

        final cards = cardFinder.evaluate().toList();
        for (var i = 0; i < cards.length; i++) {
          final accountBalance = cashBalances[i];
          final widget = cards[i].widget as CashAccountCard;
          expect(widget.accountBalance, accountBalance);
        }
      },
    );
  });
}
