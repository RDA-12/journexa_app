part of 'initialize_bloc.dart';

/// Events of [InitializeBloc]
@freezed
class InitializeEvent with _$InitializeEvent {
  /// Event to start initializing
  const factory InitializeEvent.initialize() = _Initialize;
}
