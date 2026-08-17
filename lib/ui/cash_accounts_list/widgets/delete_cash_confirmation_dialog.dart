import 'package:flutter/material.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/app_confirmation_dialog.dart';

/// Creates [AppConfirmationDialog] for confirm deleting cash account
class DeleteCashConfirmationDialog extends StatelessWidget {
  /// Creates new [DeleteCashConfirmationDialog]
  ///
  /// [onDeleted] will have true value when confirm button pressed.
  /// Otherwise, [onDeleted] will have false value.
  const DeleteCashConfirmationDialog({
    required this.account,
    required this.onDeleted,
    super.key,
  });

  /// Show [DeleteCashConfirmationDialog] in a dialog
  ///
  /// True when [account] is deleted. Otherwise, False
  static Future<bool> show(
    BuildContext context, {
    required Account account,
  }) async {
    final result = await AppConfirmationDialog.show(
      context,
      title: context.l10n.deleteCashAccountDialogTitle(account.name),
      content: context.l10n.deleteCashAccountDialogContent(account.name),
      confirmLabel: context.l10n.deleteCashAccountDialogConfirmLabel,
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
      title: context.l10n.deleteCashAccountDialogTitle(account.name),
      content: context.l10n.deleteCashAccountDialogContent(account.name),
      confirmLabel: context.l10n.deleteCashAccountDialogConfirmLabel,
      cancelLabel: context.l10n.commonCancelLabel,
      onConfirmPressed: () => onDeleted(true),
      onCancelPressed: () => onDeleted(false),
    );
  }
}
