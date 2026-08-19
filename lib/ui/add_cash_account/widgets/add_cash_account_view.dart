import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/ui/add_cash_account/bloc/add_cash_account_bloc.dart';
import 'package:journexa_app/ui/add_cash_account/widgets/cash_account_form.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';
import 'package:toastification/toastification.dart';

/// This [Widget] handles communication between [AddCashAccountBloc]
/// with [CashAccountForm]
class AddCashAccountView extends StatelessWidget {
  /// Creates new [AddCashAccountView]
  ///
  /// It reacts to [AddCashAccountBloc]'s state changes.
  /// So, make sure to provide that within the widget tree.
  const AddCashAccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddCashAccountBloc, AddCashAccountState>(
      listener: (context, state) {
        state.whenOrNull(
          added: () {
            context.showToast(
              type: ToastificationType.success,
              title: context.l10n.addCashAccountSuccessTitle,
              description: context.l10n.addCashAccountSuccessMessage,
              autoClose: true,
            );
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
      builder: (context, state) {
        final isLoading = state.maybeWhen(
          orElse: () => false,
          loading: () => true,
        );

        return CashAccountForm(
          isSaving: isLoading,
          onSavePressed: (name) {
            context.read<AddCashAccountBloc>().add(
              AddCashAccountEvent.submit(name: name),
            );
          },
        );
      },
    );
  }
}
