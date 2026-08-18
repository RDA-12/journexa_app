import 'package:flutter/material.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/ui/cash_accounts_list/widgets/delete_cash_confirmation_dialog.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/app_button.dart';
import 'package:journexa_app/ui/shared/widgets/loading_indicator.dart';

/// Creates [AppButton] with [ButtonColorType.danger]
/// that will shows [DeleteCashConfirmationDialog]
class DeleteCashButton extends StatelessWidget {
  /// Creates new [DeleteCashButton]
  const DeleteCashButton({
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
      type: ButtonType.filled,
      color: ButtonColorType.danger,
      onPressed: isDeleting
          ? null
          : () async {
              final deleted = await DeleteCashConfirmationDialog.show(
                context,
                account: account,
              );
              if (!context.mounted) return;
              if (deleted) {
                onDeletePressed?.call();
              }
            },
      icon: isDeleting
          ? const LoadingIndicator()
          : const Icon(Icons.delete_rounded),
      label: isDeleting
          ? context.l10n.commonDeletingLabel
          : context.l10n.commonDelete,
      semanticsLabel: isDeleting
          ? context.l10n.deleteCashAccountDeletingSemanticsLabel(account.name)
          : context.l10n.deleteCashAccountSemantics(account.name),
    );
  }
}
