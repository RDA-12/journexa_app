import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:journexa_app/domain/entities/journal.dart';
import 'package:journexa_app/domain/use_cases/account/get_all_cash_accounts.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';

part 'cash_accounts_event.dart';
part 'cash_accounts_state.dart';
part 'cash_accounts_bloc.freezed.dart';

/// Bloc to get all cash accounts current user have
class CashAccountsBloc extends Bloc<CashAccountsEvent, CashAccountsState>
    with GenerateUid, Loggable {
  /// Creates new [CashAccountsBloc]
  CashAccountsBloc({required this._getAllCashAccounts})
    : super(const CashAccountsState.initial()) {
    on<CashAccountsEvent>((event, emit) async {
      await event.when(
        load: () => _onLoad(emit: emit),
      );
    });
  }

  @override
  String get logTag => 'CashAccountsBloc';

  final GetAllCashAccountsUseCase _getAllCashAccounts;

  Future<void> _onLoad({
    required Emitter<CashAccountsState> emit,
  }) async {
    final traceId = generateUid();
    logInfo(
      'Starts getting cash accounts for current user. '
      'Emit loading state',
      traceId: traceId,
    );
    emit(const CashAccountsState.loading());

    final result = await _getAllCashAccounts.execute(
      traceId: traceId,
    );
    result.when(
      success: (accountBalances) {
        logInfo(
          'Get cash accounts succeeded. Emit loaded state',
          traceId: traceId,
        );
        emit(CashAccountsState.loaded(accountBalances));
      },
      failure: (exc) {
        logInfo(
          'Get cash accounts failed. Emit failure state',
          traceId: traceId,
        );
        emit(CashAccountsState.failure(exc));
      },
    );
  }
}
