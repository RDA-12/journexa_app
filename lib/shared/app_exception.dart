import 'package:flutter/foundation.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/domain/entities/wallet.dart';

/// Possibles codes for [AppException]
enum AppExceptionCode {
  /// Generic exception to catch unexpected error
  internalException,

  /// User canceling login flow
  loginCanceled,

  /// Server returns error
  serverException,

  /// Missing current user
  unauthenticated,

  /// [Account] with same name/code already exists
  accountAlreadyExists,

  /// [Account] not found
  accountNotFound,

  /// Code when creating new [Wallet] with existing name
  walletNameAlreadyExists,

  /// Code when create new [IncomeCategory] with existing name
  categoryNameAlreadyExists,

  /// Code when trying to spend more money than available in wallet
  insufficientWalletBalance,
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
