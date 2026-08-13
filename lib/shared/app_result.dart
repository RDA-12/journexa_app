import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:journexa_app/shared/app_exception.dart';

part 'app_result.freezed.dart';

/// A generic sealed class that represents the result of an operation.
///
/// It can be either a success with a value of type [T] or a failure with an
/// [AppException].
@freezed
sealed class AppResult<T> with _$AppResult<T> {
  /// Creates a new [AppResult.success] instance.
  const factory AppResult.success(T value) = AppResultSuccess;

  /// Creates a new [AppResult.failure] instance.
  const factory AppResult.failure(AppException error) = AppResultFailure;
  const AppResult._();

  /// Returns [AppException] if this is failure or null if this is success
  AppException? get errorOrNull => whenOrNull(failure: (exc) => exc);

  /// Returns value if exists. Otherwise, null
  ///
  /// Beware that if the [T] is [Null], then this getter cannot
  /// be used to check if the result is failure or success.
  /// Instead, use [errorOrNull] to check the exception or use
  /// `is` operator to check the type.
  T? get valueOrNull => whenOrNull(success: (v) => v);
}
