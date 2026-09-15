part of 'login_bloc.dart';

/// States for [LoginBloc]
@freezed
class LoginState with _$LoginState {
  /// Initial state
  const factory initial() = _Initial;

  /// Loading state
  const factory loading() = _Loading;

  /// Success state
  const factory success() = _Success;

  /// Failure state
  const factory failure(AppException error) = _Failure;
}
