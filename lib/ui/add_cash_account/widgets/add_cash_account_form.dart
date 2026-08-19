import 'package:flutter/material.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';

/// Creates new form that allows user
/// to add new cash account
class AddCashAccountForm extends StatefulWidget {
  /// Creates new [AddCashAccountForm]
  const AddCashAccountForm({
    super.key,
    this.onAddPressed,
    this.isAdding = false,
  });

  /// Invoked when user pressed add button
  final void Function(String name)? onAddPressed;

  /// Whether to show loading indicator or not
  final bool isAdding;

  @override
  State<AddCashAccountForm> createState() => _AddCashAccountFormState();
}

class _AddCashAccountFormState extends State<AddCashAccountForm> {
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
            icon: widget.isAdding
                ? const LoadingIndicator(size: 8)
                : const Icon(Icons.add_rounded),
            type: ButtonType.filled,
            onPressed: widget.isAdding
                ? null
                : () {
                    if (!_formKey.currentState!.validate()) return;
                    final name = _nameController.text.trim();
                    widget.onAddPressed?.call(name);
                  },
          ),
        ],
      ),
    );
  }
}
