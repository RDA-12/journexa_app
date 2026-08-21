import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/ui/wallets/bloc/wallets_bloc.dart';
import 'package:journexa_app/ui/wallets/widgets/wallet_card.dart';

/// Creates new [ListView] contains list of [WalletCard]
/// based on [data]
class WalletsList extends StatelessWidget {
  /// Creates new [WalletsList]
  ///
  /// It reacts to [WalletsBloc]'s changes to update [WalletCard].
  /// So, make sure to provide that bloc within the widget tree.
  const WalletsList({
    required this.data,
    required this.onDeletePressed,
    required this.onUpdatePressed,
    super.key,
  });

  /// List of data to be showed
  final List<WalletWithBalanceState> data;

  /// Invoked when delete button is pressed in [WalletCard]
  ///
  /// It means the [Wallet] confirmed to be deleted
  final void Function(Wallet) onDeletePressed;

  /// Invoked when update button is pressed in [WalletCard]
  ///
  /// It means the user confirmed to update the account name
  final void Function(Wallet, String) onUpdatePressed;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: data.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = data[index];
        return BlocSelector<WalletsBloc, WalletsState, WalletWithBalanceState?>(
          selector: (state) {
            return state.walletWithBalances.firstWhereOrNull(
              (it) =>
                  it.walletWithBalance.wallet.id ==
                  item.walletWithBalance.wallet.id,
            );
          },
          builder: (context, wallet) {
            if (wallet == null) {
              return const SizedBox.shrink();
            }
            final walletWithBalance = wallet.walletWithBalance;
            final isDeleting = wallet.status == WalletStatus.deleting;
            final isUpdating = wallet.status == WalletStatus.updating;
            return WalletCard(
              walletWithBalance: walletWithBalance,
              isDeleting: isDeleting,
              isUpdating: isUpdating,
              onUpdatePressed: (name) {
                onUpdatePressed(walletWithBalance.wallet, name);
              },
              onDeletePressed: () {
                onDeletePressed(walletWithBalance.wallet);
              },
            );
          },
        );
      },
    );
  }
}
