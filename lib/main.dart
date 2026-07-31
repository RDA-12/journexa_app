import 'package:flutter/material.dart';

void main() {
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
