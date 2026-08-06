part of 'initialize_bloc.dart';

/// States of [InitializeBloc]
@freezed
class InitializeState with _$InitializeState {
  /// Initial state
  const factory InitializeState.initial() = _Initial;

  /// Loading state
  const factory InitializeState.loading() = _Loading;

  /// Failure state
  const factory InitializeState.failure(AppException exception) = _Failure;

  /// Success state
  const factory InitializeState.initialized() = _Initialized;
}
