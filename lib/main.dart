import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:journexa_app/di.dart';
import 'package:journexa_app/firebase_options.dart';
import 'package:journexa_app/shared/app_env.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/ui/shared/app_router.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/theme.dart';

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
  const JournexaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = createTextTheme(context, 'Roboto', 'Roboto Slab');
    final theme = JournexaTheme(textTheme);

    return MaterialApp.router(
      routerConfig: AppRouter.router,
      themeMode: ThemeMode.light,
      theme: theme.light(),
      darkTheme: theme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
