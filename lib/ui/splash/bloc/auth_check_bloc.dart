import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:journexa_app/domain/use_cases/auth/check_auth.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';

part 'auth_check_event.dart';
part 'auth_check_state.dart';
part 'auth_check_bloc.freezed.dart';

/// Bloc for checking current user authentication state
class AuthCheckBloc extends Bloc<AuthCheckEvent, AuthCheckState> {
  /// Creates new [AuthCheckBloc]
  AuthCheckBloc({
    required this._checkAuth,
    required this._uidGenerator,
  }) : _logger = AppLogger('AuthCheckBloc'),
       super(const AuthCheckState.initial()) {
    on<AuthCheckEvent>((event, emit) async {
      await event.when(
        started: () => _onStarted(emit: emit),
      );
    });
  }

  final CheckAuthUseCase _checkAuth;
  final UidGenerator _uidGenerator;
  final AppLogger _logger;

  Future<void> _onStarted({required Emitter<AuthCheckState> emit}) async {
    final traceId = _uidGenerator.generateUid();
    _logger.info(
      'Start check auth state. Emit loading state',
      traceId: traceId,
    );
    emit(const AuthCheckState.loading());

    final result = await _checkAuth.execute(const NoParams(), traceId: traceId);

    result.when(
      success: (authenticated) {
        if (authenticated) {
          _logger.info(
            'User is authenticated. Emit authenticated state',
            traceId: traceId,
          );
          emit(const AuthCheckState.authenticated());
        } else {
          _logger.info(
            'User is not authenticated. Emit unauthenticated state',
            traceId: traceId,
          );
          emit(const AuthCheckState.unauthenticated());
        }
      },
      failure: (exc) {
        _logger.info(
          'Check auth state Failed. Emit failure state',
          traceId: traceId,
        );
        emit(AuthCheckState.failure(exc));
      },
    );
  }
}
