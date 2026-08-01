import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/domain/use_cases/login/login_with_google.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';

part 'login_event.dart';
part 'login_state.dart';
part 'login_bloc.freezed.dart';

/// Bloc to handles all login operations
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  /// Creates new [LoginBloc]
  LoginBloc({
    required this._loginWithGoogleUseCase,
    required this._uidGenerator,
  }) : _logger = AppLogger('LoginBloc'),
       super(const LoginState.initial()) {
    on<LoginEvent>((event, emit) async {
      await event.when(
        loginWithGoogle: () => _onLoginWithGoogle(emit: emit),
      );
    });
  }

  final UidGenerator _uidGenerator;
  final LoginWithGoogleUseCase _loginWithGoogleUseCase;
  final AppLogger _logger;

  Future<void> _onLoginWithGoogle({required Emitter<LoginState> emit}) async {
    final traceId = _uidGenerator.generateUid();
    _logger.info('Emitting loading state', traceId: traceId);
    emit(const LoginState.loading());
    final result = await _loginWithGoogleUseCase.execute(
      const NoParams(),
      traceId: traceId,
    );
    result.when(
      success: (_) {
        _logger.info(
          'Login with google success. Emitting success state',
          traceId: traceId,
        );
        return emit(const LoginState.success());
      },
      failure: (exc) {
        _logger.error(
          'Login with google failed. Emitting failure state',
          traceId: traceId,
        );
        return emit(LoginState.failure(exc));
      },
    );
  }
}
