part of 'login_bloc.dart';

/// Events for [LoginBloc]
@freezed
class LoginEvent with _$LoginEvent {
  /// Event for logging in with google account
  const factory loginWithGoogle() = _LoginWithGoogle;
}
