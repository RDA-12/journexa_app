import 'package:flutter/material.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/ui/cash_accounts_list/bloc/cash_accounts_bloc.dart';
import 'package:journexa_app/ui/cash_accounts_list/widgets/cash_account_card.dart';

/// Creates new [ListView] contains list of [CashAccountCard]
/// based on [data]
class CashAccountsList extends StatelessWidget {
  /// Creates new [CashAccountsList]
  const CashAccountsList({
    required this.data,
    required this.onDeletePressed,
    super.key,
  });

  /// List of data to be showed
  final List<AccountBalanceWithState> data;

  /// Invoke when delete button is pressed in [CashAccountCard]
  ///
  /// It means the [Account] confirmed to be deleted
  final void Function(Account) onDeletePressed;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: data.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = data[index];
        final accountBalance = item.accountBalance;
        final isDeleting = item.isDeleting;
        return CashAccountCard(
          accountBalance: accountBalance,
          isDeleting: isDeleting,
          onDeletePressed: () {
            onDeletePressed(accountBalance.account);
          },
        );
      },
    );
  }
}
