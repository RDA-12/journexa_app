import 'package:flutter/material.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/app_confirmation_dialog.dart';

/// Creates [AppConfirmationDialog] for confirm deleting wallet
class DeleteWalletConfirmationDialog extends StatelessWidget {
  /// Creates new [DeleteWalletConfirmationDialog]
  ///
  /// [onDeleted] will have true value when confirm button pressed.
  /// Otherwise, [onDeleted] will have false value.
  const DeleteWalletConfirmationDialog({
    required this.account,
    required this.onDeleted,
    super.key,
  });

  /// Show [DeleteWalletConfirmationDialog] in a dialog
  ///
  /// True when [account] is deleted. Otherwise, False
  static Future<bool> show(
    BuildContext context, {
    required Account account,
  }) async {
    final result = await AppConfirmationDialog.show(
      context,
      title: context.l10n.deleteWalletDialogTitle(account.name),
      content: context.l10n.deleteWalletDialogContent(account.name),
      confirmLabel: context.l10n.deleteWalletDialogConfirmLabel,
      cancelLabel: context.l10n.commonCancelLabel,
    );

    return result ?? false;
  }

  /// [Account] that will be deleted
  final Account account;

  /// Callback when confirm button pressed
  final ValueChanged<bool> onDeleted;

  @override
  Widget build(BuildContext context) {
    return AppConfirmationDialog(
      title: context.l10n.deleteWalletDialogTitle(account.name),
      content: context.l10n.deleteWalletDialogContent(account.name),
      confirmLabel: context.l10n.deleteWalletDialogConfirmLabel,
      cancelLabel: context.l10n.commonCancelLabel,
      onConfirmPressed: () => onDeleted(true),
      onCancelPressed: () => onDeleted(false),
    );
  }
}
