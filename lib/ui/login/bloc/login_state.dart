part of 'login_bloc.dart';

/// States for [LoginBloc]
@freezed
class LoginState with _$LoginState {
  /// Initial state
  const factory LoginState.initial() = _Initial;

  /// Loading state
  const factory LoginState.loading() = _Loading;

  /// Success state
  const factory LoginState.success() = _Success;

  /// Failure state
  const factory LoginState.failure(AppException error) = _Failure;
}
