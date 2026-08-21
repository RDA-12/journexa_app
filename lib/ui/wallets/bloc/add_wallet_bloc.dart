import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:journexa_app/domain/use_cases/wallet/add_wallet.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';

part 'add_wallet_event.dart';
part 'add_wallet_state.dart';
part 'add_wallet_bloc.freezed.dart';

/// Bloc to handle creating new wallet
class AddWalletBloc extends Bloc<AddWalletEvent, AddWalletState>
    with Loggable, GenerateUid {
  /// Creates new [AddWalletBloc]
  AddWalletBloc({
    required this._addWallet,
  }) : super(const AddWalletState.initial()) {
    on<AddWalletEvent>((event, emit) async {
      await event.when(
        submit: (name) => _onSubmit(name: name, emit: emit),
      );
    });
  }

  @override
  String get logTag => 'AddWalletBloc';

  final AddWalletUseCase _addWallet;

  Future<void> _onSubmit({
    required String name,
    required Emitter<AddWalletState> emit,
  }) async {
    final traceId = generateUid();
    logInfo(
      'Start adding new wallet. Emit loading state',
      traceId: traceId,
    );
    emit(const AddWalletState.loading());

    final result = await _addWallet.execute(
      AddWalletParams(name: name),
      traceId: traceId,
    );
    result.when(
      success: (_) {
        logInfo(
          'Add new wallet succeeded. Emit added state',
          traceId: traceId,
        );
        emit(const AddWalletState.added());
      },
      failure: (exc) {
        logInfo(
          'Add new wallet failed. Emit failure state',
          traceId: traceId,
        );
        emit(AddWalletState.failure(exc));
      },
    );
  }
}
