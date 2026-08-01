import 'package:journexa_app/shared/app_result.dart';

/// An abstract class for defining a use case with input [P] and output [R]
/// types.
///
/// Uses [FutureBaseUseCase] for async operations.
///
/// If the use case doesn't have any input, uses [NoParams].
// ignore: one_member_abstracts
abstract interface class BaseUseCase<P, R> {
  /// Executes the use case with the given parameters.
  AppResult<R> execute(P params, {required String traceId});
}

/// An abstract class for defining an asynchronous use case
/// with input [P] and output [R] types.
///
/// If the use case doesn't have any input, uses [NoParams].
// ignore: one_member_abstracts
abstract interface class FutureBaseUseCase<P, R> {
  /// Executes the use case with the given parameters.
  Future<AppResult<R>> execute(P params, {required String traceId});
}

/// A simple class to represent no parameters.
final class NoParams {
  /// Creates a new [NoParams].
  const NoParams();
}
