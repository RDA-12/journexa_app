part of 'auth_check_bloc.dart';

/// States of [AuthCheckBloc]
@freezed
class AuthCheckState with _$AuthCheckState {
  /// Intial state
  const factory initial() = _Initial;

  /// Loading state
  const factory loading() = _Loading;

  /// State when user already logged in
  const factory authenticated() = _Authenticated;

  /// State when user not logged in yet
  const factory unauthenticated() = _Unauthenticated;

  /// Failure state
  const factory failure(AppException exc) = _Failure;
}
