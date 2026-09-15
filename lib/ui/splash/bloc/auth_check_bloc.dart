import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/use_cases/auth/check_auth.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';

part 'auth_check_event.dart';
part 'auth_check_state.dart';
part 'auth_check_bloc.freezed.dart';

/// Bloc for checking current user authentication state
@injectable
class AuthCheckBloc extends Bloc<AuthCheckEvent, AuthCheckState>
    with Loggable, GenerateUid {
  /// Creates new [AuthCheckBloc]
  new({
    required this._checkAuth,
  }) : super(const AuthCheckState.initial()) {
    on<AuthCheckEvent>((event, emit) async {
      await event.when(
        started: () => _onStarted(emit: emit),
      );
    });
  }

  @override
  String get logTag => 'AuthCheckBloc';

  final CheckAuthUseCase _checkAuth;

  Future<void> _onStarted({required Emitter<AuthCheckState> emit}) async {
    final traceId = generateUid();
    logInfo(
      'Start check auth state. Emit loading state',
      traceId: traceId,
    );
    emit(const AuthCheckState.loading());

    final result = await _checkAuth.execute(traceId: traceId);

    result.when(
      success: (authenticated) {
        if (authenticated) {
          logInfo(
            'User is authenticated. Emit authenticated state',
            traceId: traceId,
          );
          emit(const AuthCheckState.authenticated());
        } else {
          logInfo(
            'User is not authenticated. Emit unauthenticated state',
            traceId: traceId,
          );
          emit(const AuthCheckState.unauthenticated());
        }
      },
      failure: (exc) {
        logInfo(
          'Check auth state Failed. Emit failure state',
          traceId: traceId,
        );
        emit(AuthCheckState.failure(exc));
      },
    );
  }
}
