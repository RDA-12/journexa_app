import 'package:flutter/material.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/app_button.dart';
import 'package:journexa_app/ui/wallets/widgets/delete_wallet_confirmation_dialog.dart';

/// Creates [AppButton] with [ButtonColorType.danger]
/// that will shows [DeleteWalletConfirmationDialog]
class DeleteWalletButton extends StatelessWidget {
  /// Creates new [DeleteWalletButton]
  const DeleteWalletButton({
    required this.account,
    this.onDeletePressed,
    this.isDeleting = false,
    super.key,
  });

  /// [Account] that will be deleted
  final Account account;

  /// Whether the [account] is in process deleting or not
  ///
  /// If true, the button is disabled.
  final bool isDeleting;

  /// Invoke when [account] confirmed to be deleted
  final VoidCallback? onDeletePressed;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      type: ButtonType.text,
      color: ButtonColorType.danger,
      onPressed: isDeleting || onDeletePressed == null
          ? null
          : () async {
              final deleted = await DeleteWalletConfirmationDialog.show(
                context,
                account: account,
              );
              if (!context.mounted) return;
              if (deleted) {
                onDeletePressed?.call();
              }
            },
      label: isDeleting
          ? context.l10n.commonDeletingLabel
          : context.l10n.commonDelete,
      semanticsLabel: isDeleting
          ? context.l10n.deleteWalletDeletingSemanticsLabel(account.name)
          : context.l10n.deleteWalletSemantics(account.name),
    );
  }
}
