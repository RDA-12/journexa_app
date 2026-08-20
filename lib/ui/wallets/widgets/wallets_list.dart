import 'package:flutter/material.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/ui/wallets/bloc/wallets_bloc.dart';
import 'package:journexa_app/ui/wallets/widgets/wallet_card.dart';

/// Creates new [ListView] contains list of [WalletCard]
/// based on [data]
class WalletsList extends StatelessWidget {
  /// Creates new [WalletsList]
  const WalletsList({
    required this.data,
    required this.onDeletePressed,
    required this.onUpdatePressed,
    super.key,
  });

  /// List of data to be showed
  final List<AccountBalanceWithState> data;

  /// Invoked when delete button is pressed in [WalletCard]
  ///
  /// It means the [Account] confirmed to be deleted
  final void Function(Account) onDeletePressed;

  /// Invoked when update button is pressed in [WalletCard]
  ///
  /// It means the user confirmed to update the account name
  final void Function(Account, String) onUpdatePressed;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: data.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = data[index];
        final accountBalance = item.accountBalance;
        final isDeleting = item.isDeleting;
        final isUpdating = item.isUpdating;
        return WalletCard(
          accountBalance: accountBalance,
          isDeleting: isDeleting,
          isUpdating: isUpdating,
          onUpdatePressed: (name) {
            onUpdatePressed(accountBalance.account, name);
          },
          onDeletePressed: () {
            onDeletePressed(accountBalance.account);
          },
        );
      },
    );
  }
}
