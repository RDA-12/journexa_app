import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journexa_app/di.dart';
import 'package:journexa_app/firebase_options.dart';
import 'package:journexa_app/shared/app_env.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/ui/auth/bloc/auth_bloc.dart';
import 'package:journexa_app/ui/router/router.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/theme.dart';
import 'package:toastification/toastification.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.initialize(debugMode: AppEnv.isDebug);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await configureDependencies();
  runApp(const JournexaApp());
}

/// Main entry widget
class JournexaApp extends StatelessWidget {
  /// Creates new [JournexaApp]
  const new({
    super.key,
    this.authBloc,
  });

  /// [AuthBloc] to be provided
  ///
  /// It will create new one when null
  final AuthBloc? authBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          (authBloc ?? getIt<AuthBloc>())
            ..add(const AuthEvent.subscriptionRequested()),
      child: ToastificationWrapper(
        config: const ToastificationConfig(
          alignment: Alignment.bottomCenter,
          maxDescriptionLines: 2,
          maxTitleLines: 1,
          maxToastLimit: 5,
        ),
        child: Builder(
          builder: (context) {
            final appRouteNotifier = AppRouteNotifier(
              authBloc: context.read<AuthBloc>(),
            );
            final router = AppRouter(
              routeNotifier: appRouteNotifier,
              redirectors: [
                const AppAuthRouteRedirector(),
              ],
            );

            return _JournexaView(
              router: router,
            );
          },
        ),
      ),
    );
  }
}

class _JournexaView extends StatelessWidget {
  const new({required this.router});

  final AppRouter router;

  @override
  Widget build(BuildContext context) {
    final textTheme = createTextTheme(context, 'Roboto', 'Roboto Slab');
    final theme = JournexaTheme(textTheme);

    return MaterialApp.router(
      routerConfig: router.config,
      themeMode: ThemeMode.light,
      theme: theme.light(),
      darkTheme: theme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
