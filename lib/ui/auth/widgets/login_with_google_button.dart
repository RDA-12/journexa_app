import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:journexa_app/ui/auth/bloc/login_bloc.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';
import 'package:toastification/toastification.dart';

/// Creates new [AppButton] specifically for
/// logging in user with Google account
class LoginWithGoogleButton extends StatelessWidget {
  /// Creates new [LoginWithGoogleButton]
  ///
  /// It uses [LoginBloc] to handle login with Google.
  /// So, make sure to provide [LoginBloc] in the widget tree.
  ///
  /// It also handles updating the UI based on [LoginState].
  /// So, usually the [onSuccess] callback is just for navigation
  /// or any other action that needs to be done after successful login.
  const new({
    super.key,
    this.onSuccess,
  });

  /// Calback when login with Google
  /// is suceeded
  final VoidCallback? onSuccess;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) {
        state.whenOrNull(
          success: () {
            onSuccess?.call();
            context.showToast(
              type: ToastificationType.success,
              title: context.l10n.loginSuccessTitle,
              description: context.l10n.loginSuccessMessage,
              autoClose: true,
            );
          },
          failure: (error) {
            context.showToast(
              type: ToastificationType.error,
              title: context.l10n.loginFailedTitle,
              description: error.code.toLocalizedString(context),
              autoClose: true,
            );
          },
        );
      },
      builder: (context, state) {
        final isLoading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        return AppButton(
          size: ButtonSize.medium,
          onPressed: isLoading
              ? null
              : () {
                  context.read<LoginBloc>().add(
                    const LoginEvent.loginWithGoogle(),
                  );
                },
          label: context.l10n.loginButtonGoogleLabel,
          icon: isLoading
              ? const LoadingIndicator(size: 16)
              : SvgPicture.asset('assets/icons/google.svg'),
        );
      },
    );
  }
}
