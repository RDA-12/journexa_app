import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/ui/add_cash_account/bloc/add_cash_account_bloc.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';
import 'package:toastification/toastification.dart';

/// Creates new form that allows user
/// to add new cash account
class AddCashAccountForm extends StatefulWidget {
  /// Creates new [AddCashAccountForm]
  ///
  /// It reacts to [AddCashAccountBloc]'s state changes.
  /// So, make sure to provide that in the widget tree.
  const AddCashAccountForm({super.key, this.onSuccess});

  /// Invoked when add cash account is successful
  final VoidCallback? onSuccess;

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
    return BlocListener<AddCashAccountBloc, AddCashAccountState>(
      listener: (context, state) {
        state.whenOrNull(
          added: () {
            context.showToast(
              type: ToastificationType.success,
              title: context.l10n.addCashAccountSuccessTitle,
              description: context.l10n.addCashAccountSuccessMessage,
              autoClose: true,
            );
            widget.onSuccess?.call();
          },
          failure: (exc) {
            final code = exc.code;
            late final String message;
            if (code == AppExceptionCode.accountAlreadyExists) {
              message = code.toLocalizedString(
                context,
                data: {
                  'name': context.l10n.commonCash,
                },
              );
            } else {
              message = code.toLocalizedString(context);
            }
            context.showToast(
              type: ToastificationType.error,
              title: context.l10n.addCashAccountFailureTitle,
              description: message,
              autoClose: true,
            );
          },
        );
      },
      child: Form(
        key: _formKey,
        child: Column(
          spacing: 16,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppFormField(
              controller: _nameController,
              isRequired: true,
              label: context.l10n.addCashAccountNameLabel,
              icon: const Icon(Icons.wallet_rounded),
            ),
            AppButton(
              label: context.l10n.addCashAccountButtonLabel,
              icon: const Icon(Icons.add_rounded),
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                context.read<AddCashAccountBloc>().add(
                  AddCashAccountEvent.submit(
                    name: _nameController.text.trim(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
