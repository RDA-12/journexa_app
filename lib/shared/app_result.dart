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

  /// Whether this result is failure or not
  bool get isFailure => this is AppResultFailure;
}
