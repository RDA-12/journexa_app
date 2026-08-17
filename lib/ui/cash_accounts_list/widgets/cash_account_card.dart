import 'package:flutter/material.dart';
import 'package:journexa_app/domain/entities/journal.dart';
import 'package:journexa_app/shared/formatter/decimal_formatter.dart';
import 'package:journexa_app/shared/formatter/string_formatter.dart';
import 'package:journexa_app/ui/cash_accounts_list/widgets/delete_cash_button.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/theme.dart';
import 'package:journexa_app/ui/shared/widgets/app_card.dart';

/// Creates new [Card] to shows [AccountBalance] data
class CashAccountCard extends StatelessWidget {
  /// Creates new [CashAccountCard]
  const CashAccountCard({
    required this.onDeletePressed,
    required this.accountBalance,
    super.key,
  });

  /// [AccountBalance] data that will be showed
  final AccountBalance accountBalance;

  /// Invoke when [DeleteCashButton] is pressed.
  ///
  /// The [DeleteCashButton] handles the confirmation dialog under the hood.
  final VoidCallback onDeletePressed;

  @override
  Widget build(BuildContext context) {
    final account = accountBalance.account;
    final balance = accountBalance.balance;
    final languageCode = context.languageCode;
    final balanceString = balance.idrCurrency(languageCode);

    return Semantics(
      container: true,
      label: '${account.name}, $balanceString',
      child: ExcludeSemantics(
        child: AppCard(
          leading: CircleAvatar(
            backgroundColor: context.color.primaryContainer,
            radius: 24,
            child: Text(account.name.initials),
          ),
          bottom: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              DeleteCashButton(
                account: account,
                onDeletePressed: onDeletePressed,
              ),
            ],
          ),
          child: Column(
            spacing: 4,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                account.name,
                style: context.text.bodySmall,
              ),
              Text(
                balanceString,
                style: context.text.headlineSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
