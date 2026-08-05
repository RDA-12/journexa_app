import 'package:flutter/foundation.dart';

/// Possibles codes for [AppException]
enum AppExceptionCode {
  /// Generic exception to catch unexpected error
  internalException,

  /// User canceling login flow
  loginCanceled,

  /// Server returns error
  serverException,
}

/// Base exception class for the application
@immutable
final class AppException implements Exception {
  /// Creates a new [AppException]
  const AppException(this.message, {required this.code});

  /// Creates new [AppException] to helps testing
  factory AppException.test() => const AppException(
    'test failure',
    code: AppExceptionCode.internalException,
  );

  /// Exception code
  final AppExceptionCode code;

  /// Exception message
  final String message;

  @override
  String toString() => '[$code] $message';

  @override
  bool operator ==(Object other) {
    return other is AppException &&
        other.runtimeType == runtimeType &&
        other.message == message &&
        other.code == code;
  }

  @override
  int get hashCode => Object.hash(message, code);
}
