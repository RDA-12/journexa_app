import 'package:flutter/foundation.dart';

/// Possibles codes for [AppException]
enum AppExceptionCode {
  /// Generic internal exception
  internalException,

  /// Login cancelled
  loginCanceled,
}

/// Base exception class for the application
@immutable
sealed class AppException implements Exception {
  /// Creates a new [AppException]
  const AppException(this.message, {required this.code});

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

/// Thrown when unexpected [Exception] thrown
final class InternalException extends AppException {
  /// Creates new [InternalException] with [message]
  const InternalException(super.message)
    : super(code: AppExceptionCode.internalException);
}

/// Thrown when user canceling login flow
final class LoginCanceledException extends AppException {
  /// Creates new [LoginCanceledException] with [message]
  const LoginCanceledException(super.message)
    : super(code: AppExceptionCode.loginCanceled);
}
