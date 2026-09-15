import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:journexa_app/di.dart';
import 'package:journexa_app/ui/splash/bloc/auth_check_bloc.dart';
import 'package:journexa_app/ui/splash/widgets/widgets.dart';

/// Page for shows splash screen.
///
/// It also checking current user authentication state
class SplashPage extends StatelessWidget {
  /// Creates new [SplashPage]
  const new({
    super.key,
    this.authCheckBloc,
  });

  /// [AuthCheckBloc] that will be provided to child
  ///
  /// It will creates new [AuthCheckBloc] when null
  final AuthCheckBloc? authCheckBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          (authCheckBloc ?? getIt<AuthCheckBloc>())
            ..add(const AuthCheckEvent.started()),
      child: const Scaffold(
        body: _SplashView(),
      ),
    );
  }
}

class _SplashView extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCheckBloc, AuthCheckState>(
      listener: (context, state) {
        state.whenOrNull(
          authenticated: () {
            context.go('/initialize');
          },
          unauthenticated: () {
            context.go('/login');
          },
        );
      },
      child: const Center(
        child: SplashBox(),
      ),
    );
  }
}
