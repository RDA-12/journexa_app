import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:journexa_app/firebase_options.dart';
import 'package:journexa_app/shared/app_env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // Set this to null when not debugging, so the Firebase uses its [options]
    demoProjectId: AppEnv.isDebug ? 'demo-journexa-app' : null,
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const JournexaApp());
}

/// Main entry widget
class JournexaApp extends StatelessWidget {
  /// Creates new [JournexaApp]
  const JournexaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
