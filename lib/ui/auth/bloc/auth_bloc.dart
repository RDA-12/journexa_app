import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/entities/user.dart';
import 'package:journexa_app/domain/use_cases/auth/watch_user.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';

part 'auth_event.dart';
part 'auth_state.dart';
part 'auth_bloc.freezed.dart';

/// Bloc to handle Auth state changes
@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> with Loggable, GenerateUid {
  /// Creates new [AuthBloc]
  new({required this._watchUser}) : super(const AuthState.initial()) {
    on<_SubscriptionRequested>(
      (event, emit) => _onSubscriptionRequested(emit: emit),
      transformer: restartable(),
    );
  }

  @override
  String get logTag => 'AuthBloc';

  final WatchUserUseCase _watchUser;

  Future<void> _onSubscriptionRequested({
    required Emitter<AuthState> emit,
  }) async {
    final traceId = generateUid();
    logInfo(
      'Starts listening for user changes. Emits loading state',
      traceId: traceId,
    );
    emit(const AuthState.loading());

    final stream = _watchUser.execute(traceId: traceId);

    await emit.forEach(
      stream,
      onData: (result) {
        return result.when(
          success: (user) {
            if (user == null) {
              return const AuthState.unauthenticated();
            }
            return AuthState.authenticated(user);
          },
          failure: (exc) {
            return const AuthState.unauthenticated();
          },
        );
      },
    );
  }
}
