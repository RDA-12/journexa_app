import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:journexa_app/ui/auth/bloc/auth_bloc.dart';
import 'package:journexa_app/ui/splash/widgets/widgets.dart';

/// Page for shows splash screen.
///
/// It also checking current user authentication state
class SplashPage extends StatelessWidget {
  /// Creates new [SplashPage]
  ///
  /// It reacts to [AuthBloc]'s state changes.
  /// So, make sure to provide it within the widget tree.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: _SplashView(),
    );
  }
}

class _SplashView extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        state.whenOrNull(
          authenticated: (_) {
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
