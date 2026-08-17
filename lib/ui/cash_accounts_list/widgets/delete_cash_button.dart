import 'package:flutter/material.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/ui/cash_accounts_list/widgets/delete_cash_confirmation_dialog.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/app_button.dart';

/// Creates [AppButton] with [ButtonColorType.danger]
/// that will shows [DeleteCashConfirmationDialog]
class DeleteCashButton extends StatelessWidget {
  /// Creates new [DeleteCashButton]
  const DeleteCashButton({
    required this.account,
    this.onDeletePressed,
    super.key,
  });

  /// [Account] that will be deleted
  final Account account;

  /// Invoke when [account] confirmed to be deleted
  final VoidCallback? onDeletePressed;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      color: ButtonColorType.danger,
      onPressed: () async {
        final deleted = await DeleteCashConfirmationDialog.show(
          context,
          account: account,
        );
        if (!context.mounted) return;
        if (deleted) {
          onDeletePressed?.call();
        }
      },
      icon: const Icon(Icons.delete_rounded),
      label: context.l10n.commonDelete,
      semanticsLabel: context.l10n.deleteCashAccountSemantics(account.name),
    );
  }
}
