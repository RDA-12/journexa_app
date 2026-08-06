part of 'auth_check_bloc.dart';

/// States of [AuthCheckBloc]
@freezed
class AuthCheckState with _$AuthCheckState {
  /// Intial state
  const factory AuthCheckState.initial() = _Initial;

  /// Loading state
  const factory AuthCheckState.loading() = _Loading;

  /// State when user already logged in
  const factory AuthCheckState.authenticated() = _Authenticated;

  /// State when user not logged in yet
  const factory AuthCheckState.unauthenticated() = _Unauthenticated;

  /// Failure state
  const factory AuthCheckState.failure(AppException exc) = _Failure;
}
