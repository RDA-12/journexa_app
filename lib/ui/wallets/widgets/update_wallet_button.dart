import 'package:flutter/material.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/app_bottom_sheet.dart';
import 'package:journexa_app/ui/shared/widgets/app_button.dart';
import 'package:journexa_app/ui/wallets/widgets/wallet_form.dart';

/// Creates new [AppButton] that will shows [WalletForm]
class UpdateWalletButton extends StatelessWidget {
  /// Creates new [UpdateWalletButton]
  const UpdateWalletButton({
    required this.account,
    required this.isUpdating,
    required this.onUpdatePressed,
    super.key,
  });

  /// [Account] that will be updated
  final Account account;

  /// Whether the button is updating
  final bool isUpdating;

  /// Invoked when [WalletForm] save button is pressed
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
                  return WalletForm(
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
          ? context.l10n.updateWalletUpdatingSemanticsLabel(account.name)
          : context.l10n.updateWalletSemantics(account.name),
    );
  }
}
