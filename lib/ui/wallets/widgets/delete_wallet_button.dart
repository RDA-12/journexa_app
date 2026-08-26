import 'package:flutter/material.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/app_button.dart';
import 'package:journexa_app/ui/shared/widgets/app_dialog.dart';

/// Creates [AppButton] with [ButtonColorType.danger]
/// that will shows [AppDialog] to shows confirmation
/// of deleting wallet
class DeleteWalletButton extends StatelessWidget {
  /// Creates new [DeleteWalletButton]
  const DeleteWalletButton({
    required this.wallet,
    this.onDeletePressed,
    this.isDeleting = false,
    super.key,
  });

  /// [Wallet] that will be deleted
  final Wallet wallet;

  /// Whether the [wallet] is in process deleting or not
  ///
  /// If true, the button is disabled.
  final bool isDeleting;

  /// Invoke when [wallet] confirmed to be deleted
  final VoidCallback? onDeletePressed;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      type: ButtonType.text,
      color: ButtonColorType.danger,
      onPressed: isDeleting || onDeletePressed == null
          ? null
          : () async {
              final deleted =
                  await context.showConfirmationDialog(
                    title: context.l10n.deleteWalletDialogTitle(wallet.name),
                    content: context.l10n.deleteWalletDialogContent(
                      wallet.name,
                    ),
                    confirmLabel: context.l10n.commonDelete,
                  ) ??
                  false;
              if (!context.mounted) return;
              if (deleted) {
                onDeletePressed?.call();
              }
            },
      label: isDeleting
          ? context.l10n.commonDeletingLabel
          : context.l10n.commonDelete,
      semanticsLabel: isDeleting
          ? context.l10n.deleteWalletDeletingSemanticsLabel(wallet.name)
          : context.l10n.deleteWalletSemantics(wallet.name),
    );
  }
}
