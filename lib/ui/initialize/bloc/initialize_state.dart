part of 'initialize_bloc.dart';

/// States of [InitializeBloc]
@freezed
class InitializeState with _$InitializeState {
  /// Initial state
  const factory initial() = _Initial;

  /// Loading state
  const factory loading() = _Loading;

  /// Failure state
  const factory failure(AppException exception) = _Failure;

  /// Success state
  const factory initialized() = _Initialized;
}
