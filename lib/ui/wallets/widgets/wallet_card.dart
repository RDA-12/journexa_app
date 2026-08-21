import 'package:flutter/material.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/shared/formatter/decimal_formatter.dart';
import 'package:journexa_app/shared/formatter/string_formatter.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/theme.dart';
import 'package:journexa_app/ui/shared/widgets/app_card.dart';
import 'package:journexa_app/ui/wallets/widgets/delete_wallet_button.dart';
import 'package:journexa_app/ui/wallets/widgets/update_wallet_button.dart';

/// Creates new [Card] to shows [WalletWithBalance] data
class WalletCard extends StatelessWidget {
  /// Creates new [WalletCard]
  const WalletCard({
    required this.onDeletePressed,
    required this.walletWithBalance,
    required this.onUpdatePressed,
    this.isDeleting = false,
    this.isUpdating = false,
    super.key,
  });

  /// [WalletWithBalance] data that will be showed
  final WalletWithBalance walletWithBalance;

  /// Whether this wallet is in process of deleting
  final bool isDeleting;

  /// Invoke when [DeleteWalletButton] is pressed.
  ///
  /// The [DeleteWalletButton] handles the confirmation dialog under the hood.
  final VoidCallback onDeletePressed;

  /// Invoke when [UpdateWalletButton] is pressed.
  ///
  /// The [UpdateWalletButton] handles the confirmation dialog under the hood.
  final void Function(String) onUpdatePressed;

  /// Whether this wallet is in process of updating
  final bool isUpdating;

  @override
  Widget build(BuildContext context) {
    final wallet = walletWithBalance.wallet;
    final balance = walletWithBalance.balance;
    final languageCode = context.languageCode;
    final balanceString = balance.idrCurrency(languageCode);

    return AppCard(
      leading: CircleAvatar(
        backgroundColor: context.color.primaryContainer,
        radius: 24,
        child: Text(wallet.name.initials),
      ),
      bottom: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          DeleteWalletButton(
            wallet: wallet,
            isDeleting: isDeleting,
            onDeletePressed: isDeleting || isUpdating ? null : onDeletePressed,
          ),
          UpdateWalletButton(
            wallet: wallet,
            isUpdating: isUpdating,
            onUpdatePressed: isDeleting || isUpdating ? null : onUpdatePressed,
          ),
        ],
      ),
      child: Semantics(
        container: true,
        excludeSemantics: true,
        label: context.l10n.walletAccountCardSemantics(
          wallet.name,
          balanceString,
        ),
        child: Column(
          spacing: 4,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              wallet.name,
              style: context.text.bodySmall,
            ),
            Text(
              balanceString,
              style: context.text.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}
