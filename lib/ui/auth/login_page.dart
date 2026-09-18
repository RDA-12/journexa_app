import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journexa_app/di.dart';
import 'package:journexa_app/ui/auth/bloc/login_bloc.dart';
import 'package:journexa_app/ui/auth/widgets/widgets.dart';
import 'package:journexa_app/ui/router/router.dart';

/// Page for login functionality.
class LoginPage extends StatelessWidget {
  /// Creates new [LoginPage]
  const new({super.key, this.loginBloc});

  /// [LoginBloc] that will be provided to the widget.
  ///
  /// If null, will creates new [LoginBloc].
  final LoginBloc? loginBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => loginBloc ?? getIt<LoginBloc>(),
      child: const Scaffold(
        body: _LoginView(),
      ),
    );
  }
}

class _LoginView extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        spacing: 128,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LoginHeader(),
          LoginWithGoogleButton(
            onSuccess: () {
              const InitializeRoute().go(context);
            },
          ),
        ],
      ),
    );
  }
}
