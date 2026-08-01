import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:journexa_app/ui/login_button/bloc/login_bloc.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';

/// Creates new [AppOutlinedButton] specifically for
/// logging in user with Google account
class LoginWithGoogleButton extends StatelessWidget {
  /// Creates new [LoginWithGoogleButton]
  ///
  /// It uses [LoginBloc] to handle login with Google.
  /// So, make sure to provide [LoginBloc] in the widget tree.
  const LoginWithGoogleButton({
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
          },
        );
      },
      builder: (context, state) {
        final isLoading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        return AppOutlinedButton(
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
