part of 'auth_bloc.dart';

/// States for [AuthState]
@freezed
class AuthState with _$AuthState {
  /// Initial state
  const factory initial() = _Initial;

  /// State when no user logged in
  const factory unauthenticated() = _Unauthenticated;

  /// States when a user already logged in
  const factory authenticated(User user) = _Authenticated;

  /// States when waiting for auth result
  const factory loading() = _Loading;
}
