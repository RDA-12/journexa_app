import 'package:flutter/material.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';

/// Creates new form that allows user
/// to add new cash account
class CashAccountForm extends StatefulWidget {
  /// Creates new [CashAccountForm]
  const CashAccountForm({
    super.key,
    this.onSavePressed,
    this.isSaving = false,
  });

  /// Invoked when user pressed add button
  final void Function(String name)? onSavePressed;

  /// Whether to show loading indicator or not
  final bool isSaving;

  @override
  State<CashAccountForm> createState() => _CashAccountFormState();
}

class _CashAccountFormState extends State<CashAccountForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

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
            label: context.l10n.addCashAccountNameLabel,
            icon: const Icon(Icons.wallet_rounded),
          ),
          AppButton(
            label: context.l10n.addCashAccountButtonLabel,
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
