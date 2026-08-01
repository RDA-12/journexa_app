import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:journexa_app/di.dart';
import 'package:journexa_app/domain/use_cases/login/login_with_google.dart';
import 'package:journexa_app/shared/uid_generator.dart';
import 'package:journexa_app/ui/login/widgets/login_header.dart';
import 'package:journexa_app/ui/login_button/bloc/login_bloc.dart';
import 'package:journexa_app/ui/login_button/widgets/widgets.dart';

/// Page for login functionality.
class LoginPage extends StatelessWidget {
  /// Creates new [LoginPage]
  const LoginPage({super.key, this.loginBloc});

  /// [LoginBloc] that will be provided to the widget.
  ///
  /// If null, will creates new [LoginBloc].
  final LoginBloc? loginBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          loginBloc ??
          LoginBloc(
            loginWithGoogleUseCase: getIt<LoginWithGoogleUseCase>(),
            uidGenerator: getIt<UidGenerator>(),
          ),
      child: const Scaffold(
        body: _LoginView(),
      ),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

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
              context.go('/');
            },
          ),
        ],
      ),
    );
  }
}
