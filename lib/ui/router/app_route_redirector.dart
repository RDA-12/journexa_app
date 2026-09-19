import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:journexa_app/ui/auth/bloc/auth_bloc.dart';
import 'package:journexa_app/ui/router/router.dart';

/// A class to check whether user need to be redirected to other page or not
abstract interface class AppRouteRedirector {
  /// Returns new location the user must be redirect to.
  /// Otherwise, null, means the user doesn't need to be redirected
  String? maybeRedirect(BuildContext context, GoRouterState state);
}

/// A redirector to check for current user auth state.
///
/// It will redirect user to login when auth state is unauthenticated
class AppAuthRouteRedirector implements AppRouteRedirector {
  /// Creates new [AppAuthRouteRedirector]
  const new();

  @override
  String? maybeRedirect(BuildContext context, GoRouterState state) {
    final authState = context.read<AuthBloc>().state;
    final splashLocation = const SplashRoute().location;
    final loginLocation = const LoginRoute().location;
    final homeLocation = const HomeRoute().location;

    return authState.maybeWhen(
      authenticated: (user) {
        if ([splashLocation, loginLocation].contains(state.matchedLocation)) {
          return homeLocation;
        }
        return null;
      },
      unauthenticated: () {
        if (state.matchedLocation != loginLocation) {
          return loginLocation;
        }
        return null;
      },
      orElse: () => null,
    );
  }
}
