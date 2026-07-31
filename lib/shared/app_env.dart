/// Global environment variables
abstract class AppEnv {
  /// Environment
  ///
  /// Default to `debug`
  static const String env = String.fromEnvironment(
    'ENV',
    defaultValue: 'debug',
  );

  /// Whether current environment is in debug of not
  static bool get isDebug => env == 'debug';
}
