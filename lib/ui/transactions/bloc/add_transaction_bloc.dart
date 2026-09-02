import 'package:bloc/bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/use_cases/transaction/transfer_money.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';

part 'add_transaction_event.dart';
part 'add_transaction_state.dart';
part 'add_transaction_bloc.freezed.dart';

/// Bloc to handle adding new Transaction
class AddTransactionBloc extends Bloc<AddTransactionEvent, AddTransactionState>
    with Loggable, GenerateUid {
  /// Creates new [AddTransactionBloc]
  AddTransactionBloc({
    required this._transferMoney,
  }) : super(const AddTransactionState.initial()) {
    on<AddTransactionEvent>(
      (event, emit) async {
        await event.when(
          transfer: (source, destination, amount, fee, date, notes) {
            return _onTransfer(
              emit: emit,
              source: source,
              destination: destination,
              amount: amount,
              fee: fee,
              date: date,
              notes: notes,
            );
          },
        );
      },
    );
  }

  final TransferMoneyUseCase _transferMoney;

  @override
  String get logTag => 'AddTransactionBloc';

  Future<void> _onTransfer({
    required Emitter<AddTransactionState> emit,
    required Wallet source,
    required Wallet destination,
    required Decimal amount,
    required Decimal fee,
    required DateTime date,
    String? notes,
  }) async {
    final traceId = generateUid();
    logInfo(
      'Starts adding new transfer money. Emit loading state',
      traceId: traceId,
      extras: {
        'sourceId': source.id,
        'destinationId': destination.id,
        'amount': amount,
        'date': date,
        'notes': notes,
      },
    );
    emit(const AddTransactionState.loading());
    final result = await _transferMoney.execute(
      TransferMoneyParams(
        source: source,
        destination: destination,
        amount: amount,
        fee: fee,
        date: date,
        notes: notes,
      ),
      traceId: traceId,
    );
    result.when(
      success: (transaction) {
        logInfo(
          'Transfer money success. Emit added state',
          traceId: traceId,
          extras: {'transactionId': transaction.id},
        );
        emit(AddTransactionState.added(transaction));
      },
      failure: (error) {
        logError(
          'Transfer money failed. Emit failure state',
          traceId: traceId,
          error: error,
        );
        emit(AddTransactionState.failure(error));
      },
    );
  }
}
