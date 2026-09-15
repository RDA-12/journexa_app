import 'package:flutter/material.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';

/// Creates new form that allows user
/// to add new wallet
class WalletForm extends StatefulWidget {
  /// Creates new [WalletForm]
  const new({
    super.key,
    this.initialWallet,
    this.onSavePressed,
    this.isSaving = false,
  });

  /// Initial account to be showed
  final Wallet? initialWallet;

  /// Invoked when user pressed add button
  final void Function(String name)? onSavePressed;

  /// Whether to show loading indicator or not
  final bool isSaving;

  @override
  State<WalletForm> createState() => _WalletFormState();
}

class _WalletFormState extends State<WalletForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialWallet?.name ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        spacing: 16,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppFormField(
            controller: _nameController,
            isRequired: true,
            label: context.l10n.addWalletNameLabel,
            icon: const Icon(Icons.wallet_rounded),
          ),
          AppButton(
            label: context.l10n.commonSaveLabel,
            icon: widget.isSaving
                ? const LoadingIndicator(size: 8)
                : const Icon(Icons.add_rounded),
            type: ButtonType.filled,
            onPressed: widget.isSaving
                ? null
                : () {
                    if (!_formKey.currentState!.validate()) return;
                    final name = _nameController.text.trim();
                    widget.onSavePressed?.call(name);
                  },
          ),
        ],
      ),
    );
  }
}
