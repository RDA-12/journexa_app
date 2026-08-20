import 'package:flutter/material.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/ui/accounts/widgets/cash_account_form.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/app_bottom_sheet.dart';
import 'package:journexa_app/ui/shared/widgets/app_button.dart';

/// Creates new [AppButton] that will shows [CashAccountForm]
class UpdateCashButton extends StatelessWidget {
  /// Creates new [UpdateCashButton]
  const UpdateCashButton({
    required this.account,
    required this.isUpdating,
    required this.onUpdatePressed,
    super.key,
  });

  /// [Account] that will be updated
  final Account account;

  /// Whether the button is updating
  final bool isUpdating;

  /// Invoked when [CashAccountForm] save button is pressed
  final void Function(String name)? onUpdatePressed;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      type: ButtonType.text,
      onPressed: isUpdating || onUpdatePressed == null
          ? null
          : () async {
              await context.showBottomModal<void>(
                builder: (context) {
                  return CashAccountForm(
                    initialAccount: account,
                    onSavePressed: (name) {
                      onUpdatePressed?.call(name);
                      Navigator.pop(context);
                    },
                  );
                },
              );
            },
      label: isUpdating
          ? context.l10n.commonUpdatingLabel
          : context.l10n.commonUpdateLabel,
      semanticsLabel: isUpdating
          ? context.l10n.updateCashAccountUpdatingSemanticsLabel(account.name)
          : context.l10n.updateCashAccountSemantics(account.name),
    );
  }
}
