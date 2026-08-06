part of 'auth_check_bloc.dart';

/// Events for [AuthCheckBloc]
@freezed
class AuthCheckEvent with _$AuthCheckEvent {
  /// Event to start checking auth state
  const factory AuthCheckEvent.started() = _Started;
}
