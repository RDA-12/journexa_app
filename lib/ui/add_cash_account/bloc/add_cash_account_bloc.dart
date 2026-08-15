import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:journexa_app/domain/use_cases/account/add_cash_account.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';

part 'add_cash_account_event.dart';
part 'add_cash_account_state.dart';
part 'add_cash_account_bloc.freezed.dart';

/// Bloc to handle creating new cash account
class AddCashAccountBloc extends Bloc<AddCashAccountEvent, AddCashAccountState>
    with Loggable {
  /// Creates new [AddCashAccountBloc]
  AddCashAccountBloc({
    required this._addCashAccount,
    required this._uidGenerator,
  }) : super(const AddCashAccountState.initial()) {
    on<AddCashAccountEvent>((event, emit) async {
      await event.when(
        submit: (name) => _onSubmit(name: name, emit: emit),
      );
    });
  }

  @override
  String get logTag => 'AddCashAccountBloc';

  final AddCashAccountUseCase _addCashAccount;
  final UidGenerator _uidGenerator;

  Future<void> _onSubmit({
    required String name,
    required Emitter<AddCashAccountState> emit,
  }) async {
    final traceId = _uidGenerator.generateUid();
    logInfo(
      'Start adding new cash account. Emit loading state',
      traceId: traceId,
    );
    emit(const AddCashAccountState.loading());

    final result = await _addCashAccount.execute(
      AddCashAccountParams(name: name),
      traceId: traceId,
    );
    result.when(
      success: (_) {
        logInfo(
          'Add new cash account succeeded. Emit added state',
          traceId: traceId,
        );
        emit(const AddCashAccountState.added());
      },
      failure: (exc) {
        logInfo(
          'Add new cash account failed. Emit failure state',
          traceId: traceId,
        );
        emit(AddCashAccountState.failure(exc));
      },
    );
  }
}
