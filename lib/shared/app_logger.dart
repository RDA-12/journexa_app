import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:journexa_app/shared/formatter/formatter.dart';
import 'package:logging/logging.dart';

part 'app_logger.freezed.dart';
part 'app_logger.g.dart';

/// Logger used across the app
///
/// Calls [initialize] once before `runApp`
class AppLogger {
  /// Creates new [AppLogger] with optional [logger]
  ///
  /// [name] will be ignored when [logger] provided
  new(String name, {Logger? logger}) : _logger = logger ?? Logger(name);

  final Logger _logger;

  /// Initializes logger to log messages on console
  ///
  /// Call once before `runApp`
  static void initialize({bool debugMode = false}) {
    Logger.root.level = debugMode ? Level.ALL : Level.INFO;
    Logger.root.onRecord.listen((record) {
      final data = record.object;
      if (data is LogMessage) {
        debugPrint(
          '[${data.traceId}] '
          '${data.timestamp.dateTimeFormat} [${data.level.name}] '
          '${data.name}: ${data.message}',
        );
        if (data.extras != null) {
          debugPrint('[${data.traceId}]--- EXTRAS ---');
          data.extras!.forEach((key, value) {
            debugPrint('[${data.traceId}][$key]: $value');
          });
          debugPrint('[${data.traceId}]--- END EXTRAS ---');
        }
      } else {
        debugPrint(record.message);
      }
    });
  }

  /// Logs debug [message] with additional [extras]
  ///
  /// Safe to log any credentials
  void debug(
    String message, {
    required String traceId,
    Map<String, dynamic>? extras,
  }) {
    final formatted = LogMessage(
      name: _logger.name,
      level: Level.FINE,
      message: message,
      extras: extras,
      traceId: traceId,
    );
    _logger.fine(formatted);
  }

  /// Logs info [message] with additional [extras]
  ///
  /// NEVER includes any credentials as it will be
  /// send to analytics aggregator
  void info(
    String message, {
    required String traceId,
    Map<String, dynamic>? extras,
  }) {
    final formatted = LogMessage(
      name: _logger.name,
      level: Level.INFO,
      message: message,
      extras: extras,
      traceId: traceId,
    );
    _logger.info(formatted);
  }

  /// Logs warning [message] with additional [extras]
  ///
  /// NEVER includes any credentials as it will be
  /// send to analytics aggregator
  void warning(
    String message, {
    required String traceId,
    Map<String, dynamic>? extras,
  }) {
    final formatted = LogMessage(
      name: _logger.name,
      level: Level.WARNING,
      message: message,
      extras: extras,
      traceId: traceId,
    );
    _logger.warning(formatted);
  }

  /// Logs error [message] with additional [extras]
  ///
  /// NEVER includes any credentials as it will be
  /// send to analytics aggregator
  void error(
    String message, {
    required String traceId,
    Map<String, dynamic>? extras,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final formatted = LogMessage(
      name: _logger.name,
      level: Level.SEVERE,
      message: message,
      extras: extras,
      traceId: traceId,
    );
    _logger.severe(formatted);
  }
}

/// Represents a single log message
///
/// Should be used to log messages in JSON format to console
@freezed
sealed class LogMessage with _$LogMessage {
  /// Creates new [LogMessage]
  factory({
    /// Logger name
    required String name,

    /// Log level
    @JsonKey(toJson: _levelToJson, fromJson: _levelFromJson)
    required Level level,

    /// Message to log
    required String message,

    /// Trace ID
    required String traceId,

    /// Optional extra data to log
    Map<String, dynamic>? extras,

    /// Log timestamp
    DateTime? timestamp,
  }) = _LogMessage;
  new _({DateTime? timestamp}) : timestamp = timestamp ?? clock.now();

  /// Creates [LogMessage] from [json]
  factory fromJson(Map<String, dynamic> json) => _$LogMessageFromJson(json);

  /// Log timestamp
  final DateTime timestamp;
}

/// Converts [level] to [String]
String _levelToJson(Level level) => level.name;

/// Converts [json] to [Level]
Level _levelFromJson(String json) => Level(
  json,
  Level.LEVELS
          .cast<Level?>()
          .firstWhere(
            (it) => it?.name == json,
            orElse: () => null,
          )
          ?.value ??
      1,
);

/// Mixin to use in classes that need to log messages
mixin Loggable {
  /// Tag used to identify the logger
  String get logTag;

  /// Logger instance
  late final AppLogger _logger = AppLogger(logTag);

  /// Logs debug [message] with additional [extras]
  void logDebug(
    String message, {
    required String traceId,
    Map<String, dynamic>? extras,
  }) => _logger.debug(message, traceId: traceId, extras: extras);

  /// Logs info [message] with additional [extras]
  void logInfo(
    String message, {
    required String traceId,
    Map<String, dynamic>? extras,
  }) => _logger.info(message, traceId: traceId, extras: extras);

  /// Logs warning [message] with additional [extras]
  void logWarning(
    String message, {
    required String traceId,
    Map<String, dynamic>? extras,
  }) => _logger.warning(message, traceId: traceId, extras: extras);

  /// Logs error [message] with additional [extras]
  void logError(
    String message, {
    required String traceId,
    Map<String, dynamic>? extras,
    Object? error,
    StackTrace? stackTrace,
  }) => _logger.error(
    message,
    traceId: traceId,
    extras: extras,
    error: error,
    stackTrace: stackTrace,
  );
}
