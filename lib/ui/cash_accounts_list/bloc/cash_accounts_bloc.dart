import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/journal.dart';
import 'package:journexa_app/domain/use_cases/account/delete_account.dart';
import 'package:journexa_app/domain/use_cases/account/get_all_cash_accounts.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';
import 'package:journexa_app/ui/shared/event_transform/debounce.dart';

part 'cash_accounts_event.dart';
part 'cash_accounts_state.dart';
part 'cash_accounts_bloc.freezed.dart';

/// Bloc to get all cash accounts current user have
class CashAccountsBloc extends Bloc<CashAccountsEvent, CashAccountsState>
    with GenerateUid, Loggable {
  /// Creates new [CashAccountsBloc]
  CashAccountsBloc({
    required this._getAllCashAccounts,
    required this._deleteAccount,
  }) : super(const CashAccountsState()) {
    on<_Load>((event, emit) async {
      return _onLoad(
        emit: emit,
        params: const GetAllCashAccountsParams(),
      );
    });
    on<_Search>(
      (event, emit) async {
        return _onLoad(
          emit: emit,
          params: GetAllCashAccountsParams(query: event.query),
        );
      },
      transformer: debounce(),
    );
    on<_Delete>(
      (event, emit) async {
        return _onDelete(account: event.account, emit: emit);
      },
      transformer: droppable(),
    );
  }

  @override
  String get logTag => 'CashAccountsBloc';

  final GetAllCashAccountsUseCase _getAllCashAccounts;
  final DeleteAccountUseCase _deleteAccount;

  Future<void> _onLoad({
    required Emitter<CashAccountsState> emit,
    required GetAllCashAccountsParams params,
  }) async {
    final traceId = generateUid();
    logInfo(
      'Starts getting cash accounts for current user. '
      'Emit loading status',
      traceId: traceId,
    );
    emit(state.copyWith(status: CashAccountsStatus.loading));

    final result = await _getAllCashAccounts.execute(
      params,
      traceId: traceId,
    );
    result.when(
      success: (accountBalances) {
        logInfo(
          'Get cash accounts succeeded. Emit loaded status',
          traceId: traceId,
        );
        emit(
          state.copyWith(
            status: CashAccountsStatus.loaded,
            accountBalances: accountBalances
                .map((it) => AccountBalanceWithState(accountBalance: it))
                .toList(),
          ),
        );
      },
      failure: (exc) {
        logInfo(
          'Get cash accounts failed. Emit failure status',
          traceId: traceId,
        );
        emit(
          state.copyWith(
            status: CashAccountsStatus.failure,
            exception: exc,
          ),
        );
      },
    );
  }

  Future<void> _onDelete({
    required Account account,
    required Emitter<CashAccountsState> emit,
  }) async {
    final traceId = generateUid();
    final accountIdx = state.accountBalances.indexWhere(
      (it) => it.accountBalance.account.code == account.code,
    );
    if (accountIdx == -1) {
      logInfo(
        'Account with code ${account.code} not found in accountBalances. '
        'Early return',
        traceId: traceId,
      );
      return;
    }

    logInfo(
      'Starts deleting account with code ${account.code}. '
      'Emit new accountBalances with isDeleting = true on the Account',
      traceId: traceId,
    );
    emit(
      state.copyWith(
        accountBalances: state.accountBalances.map((it) {
          final isDeleting = it.accountBalance.account.code == account.code;
          return it.copyWith(isDeleting: isDeleting);
        }).toList(),
      ),
    );
    final result = await _deleteAccount.execute(
      DeleteAccountParams(account: account),
      traceId: traceId,
    );
    result.when(
      success: (_) {
        logInfo(
          'Deletes account success. '
          'Filter account from accountBalances',
          traceId: traceId,
        );
        emit(
          state.copyWith(
            status: CashAccountsStatus.loaded,
            accountBalances: state.accountBalances
                .where((it) => it.accountBalance.account.code != account.code)
                .toList(),
          ),
        );
      },
      failure: (exc) {
        logInfo(
          'Delete account failed. Emit deleteFailure status',
          traceId: traceId,
        );
        emit(
          state.copyWith(
            status: CashAccountsStatus.deleteFailure,
            deleteException: exc,
            accountBalances: state.accountBalances.map((it) {
              final processed = it.accountBalance.account.code == account.code;
              if (!processed) return it;
              return it.copyWith(isDeleting: false);
            }).toList(),
          ),
        );
      },
    );
  }
}
