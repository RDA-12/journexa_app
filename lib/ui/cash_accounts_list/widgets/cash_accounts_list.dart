import 'package:flutter/material.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/journal.dart';
import 'package:journexa_app/ui/cash_accounts_list/widgets/cash_account_card.dart';

/// Creates new [ListView] contains list of [CashAccountCard]
/// based on [accountBalances]
class CashAccountsList extends StatelessWidget {
  /// Creates new [CashAccountsList]
  const CashAccountsList({
    required this.accountBalances,
    required this.onDeletePressed,
    super.key,
  });

  /// List of [AccountBalance] to be showed
  final List<AccountBalance> accountBalances;

  /// Invoke when delete button is pressed in [CashAccountCard]
  ///
  /// It means the [Account] confirmed to be deleted
  final void Function(Account) onDeletePressed;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: accountBalances.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final accountBalance = accountBalances[index];
        return CashAccountCard(
          accountBalance: accountBalance,
          onDeletePressed: () {
            onDeletePressed(accountBalance.account);
          },
        );
      },
    );
  }
}
