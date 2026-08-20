import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';
import 'package:journexa_app/ui/wallets/bloc/add_wallet_bloc.dart';
import 'package:journexa_app/ui/wallets/widgets/wallet_form.dart';
import 'package:toastification/toastification.dart';

/// This [Widget] handles communication between [AddWalletBloc]
/// with [WalletForm]
class AddWalletView extends StatelessWidget {
  /// Creates new [AddWalletView]
  ///
  /// It reacts to [AddWalletBloc]'s state changes.
  /// So, make sure to provide that within the widget tree.
  const AddWalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddWalletBloc, AddWalletState>(
      listener: (context, state) {
        state.whenOrNull(
          added: () {
            context.showToast(
              type: ToastificationType.success,
              title: context.l10n.addWalletSuccessTitle,
              description: context.l10n.addWalletSuccessMessage,
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
                  'name': context.l10n.commonWallet,
                },
              );
            } else {
              message = code.toLocalizedString(context);
            }
            context.showToast(
              type: ToastificationType.error,
              title: context.l10n.addWalletFailureTitle,
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

        return WalletForm(
          isSaving: isLoading,
          onSavePressed: (name) {
            context.read<AddWalletBloc>().add(
              AddWalletEvent.submit(name: name),
            );
          },
        );
      },
    );
  }
}
