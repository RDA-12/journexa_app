import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:journexa_app/domain/use_cases/account/initialize_accounts.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';

part 'initialize_event.dart';
part 'initialize_state.dart';
part 'initialize_bloc.freezed.dart';

/// Bloc to handle initialize operations
///
/// It includes initialization of default system accounts.
class InitializeBloc extends Bloc<InitializeEvent, InitializeState>
    with Loggable, GenerateUid {
  /// Creates new [InitializeBloc]
  InitializeBloc({
    required this._initializeAccounts,
  }) : super(const InitializeState.initial()) {
    on<InitializeEvent>((event, emit) async {
      await event.when(
        initialize: () => _onInitialize(emit: emit),
      );
    });
  }

  @override
  String get logTag => 'InitializeBloc';

  final InitializeAccountsUseCase _initializeAccounts;

  Future<void> _onInitialize({
    required Emitter<InitializeState> emit,
  }) async {
    final traceId = generateUid();
    logInfo('Start initialization. Emit loading state', traceId: traceId);
    emit(const InitializeState.loading());
    final result = await _initializeAccounts.execute(
      const NoParams(),
      traceId: traceId,
    );
    result.when(
      success: (_) {
        logInfo(
          'Initialization success. Emit initialized state',
          traceId: traceId,
        );
        return emit(const InitializeState.initialized());
      },
      failure: (exc) {
        logInfo(
          'Initialization failed. Emit failure state',
          traceId: traceId,
        );
        return emit(InitializeState.failure(exc));
      },
    );
  }
}
