import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/journal.dart';
import 'package:journexa_app/domain/use_cases/account/delete_account.dart';
import 'package:journexa_app/domain/use_cases/account/update_account.dart';
import 'package:journexa_app/domain/use_cases/wallet/get_all_wallets.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';
import 'package:journexa_app/ui/shared/event_transform/debounce.dart';

part 'wallets_event.dart';
part 'wallets_state.dart';
part 'wallets_bloc.freezed.dart';

/// Bloc to get all wallets current user have
class WalletsBloc extends Bloc<WalletsEvent, WalletsState>
    with GenerateUid, Loggable {
  /// Creates new [WalletsBloc]
  WalletsBloc({
    required this._getAllWallets,
    required this._deleteAccount,
    required this._updateAccount,
  }) : super(const WalletsState()) {
    on<_Load>((event, emit) async {
      return _onLoad(
        emit: emit,
        params: const GetAllWalletsParams(),
      );
    });
    on<_Search>(
      (event, emit) async {
        return _onLoad(
          emit: emit,
          params: GetAllWalletsParams(query: event.query),
        );
      },
      transformer: debounce(),
    );
    on<_Delete>(
      (event, emit) async {
        return _onDelete(account: event.account, emit: emit);
      },
    );
    on<_Update>(
      (event, emit) async {
        return _onUpdate(
          account: event.account,
          emit: emit,
          name: event.name,
        );
      },
    );
  }

  @override
  String get logTag => 'WalletsBloc';

  final GetAllWalletsUseCase _getAllWallets;
  final DeleteAccountUseCase _deleteAccount;
  final UpdateAccountUseCase _updateAccount;

  Future<void> _onLoad({
    required Emitter<WalletsState> emit,
    required GetAllWalletsParams params,
  }) async {
    final traceId = generateUid();
    logInfo(
      'Starts getting wallets for current user. '
      'Emit loading status',
      traceId: traceId,
    );
    emit(state.copyWith(status: WalletsStatus.loading));

    final result = await _getAllWallets.execute(
      params,
      traceId: traceId,
    );
    result.when(
      success: (accountBalances) {
        logInfo(
          'Get wallets succeeded. Emit loaded status',
          traceId: traceId,
        );
        emit(
          state.copyWith(
            status: WalletsStatus.loaded,
            accountBalances: accountBalances
                .map((it) => AccountBalanceWithState(accountBalance: it))
                .toList(),
          ),
        );
      },
      failure: (exc) {
        logInfo(
          'Get wallets failed. Emit failure status',
          traceId: traceId,
        );
        emit(
          state.copyWith(
            status: WalletsStatus.failure,
            exception: exc,
          ),
        );
      },
    );
  }

  Future<void> _onDelete({
    required Account account,
    required Emitter<WalletsState> emit,
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
      'Emit new accountBalances with status deleting on the Account',
      traceId: traceId,
    );
    emit(
      state.copyWith(
        accountBalances: state.accountBalances.map((it) {
          final isDeleting = it.accountBalance.account.code == account.code;
          if (!isDeleting) return it;
          return it.copyWith(status: WalletStatus.deleting);
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
          'Filter account from accountBalances. '
          'Emit with recentlyDeleted notice',
          traceId: traceId,
        );
        emit(
          state.copyWith(
            status: WalletsStatus.loaded,
            accountBalances: state.accountBalances
                .where((it) => it.accountBalance.account.code != account.code)
                .toList(),
            notice: WalletNotice.recentlyDeleted(account: account),
          ),
        );
      },
      failure: (exc) {
        logInfo(
          'Delete account failed. '
          'Emit idle status on the Account with deleteFailed notice',
          traceId: traceId,
        );
        emit(
          state.copyWith(
            status: WalletsStatus.loaded,
            accountBalances: state.accountBalances.map((it) {
              final processed = it.accountBalance.account.code == account.code;
              if (!processed) return it;
              return it.copyWith(status: WalletStatus.idle);
            }).toList(),
            notice: WalletNotice.deleteFailed(
              account: account,
              exception: exc,
            ),
          ),
        );
      },
    );
  }

  Future<void> _onUpdate({
    required Account account,
    required Emitter<WalletsState> emit,
    String? name,
  }) async {
    final traceId = generateUid();
    logInfo('Checking account with code ${account.code}', traceId: traceId);
    final accountIdx = state.accountBalances.indexWhere(
      (it) => it.accountBalance.account.code == account.code,
    );
    if (accountIdx == -1) {
      logInfo('Account not found. Skipping', traceId: traceId);
      return;
    }
    final oldAccount = state.accountBalances[accountIdx].accountBalance.account;

    logInfo(
      'Starts updating account ${account.code}. '
      'Emit new accountBalances with status updateing on the Account',
      traceId: traceId,
    );
    emit(
      state.copyWith(
        accountBalances: state.accountBalances.map((it) {
          final isUpdating = it.accountBalance.account.code == account.code;
          if (!isUpdating) return it;
          return it.copyWith(status: WalletStatus.updating);
        }).toList(),
      ),
    );

    final params = UpdateAccountParams(
      code: account.code,
      name: name,
    );
    final result = await _updateAccount.execute(params, traceId: traceId);
    result.when(
      success: (updated) {
        logInfo(
          'Updates account success. '
          'Emit updated account with idle status and recentlyUpdated notice',
          traceId: traceId,
        );
        emit(
          state.copyWith(
            status: WalletsStatus.loaded,
            accountBalances: state.accountBalances.map((it) {
              final processed = it.accountBalance.account.code == account.code;
              if (!processed) return it;
              return it.copyWith(
                status: WalletStatus.idle,
                accountBalance: it.accountBalance.copyWith(account: updated),
              );
            }).toList(),
            notice: WalletNotice.recentlyUpdated(
              from: oldAccount,
              to: updated,
            ),
          ),
        );
      },
      failure: (exc) {
        logInfo(
          'Update account failed. '
          'Emit idel status on the Account and updateFailed notice',
          traceId: traceId,
        );
        emit(
          state.copyWith(
            status: WalletsStatus.loaded,
            accountBalances: state.accountBalances.map((it) {
              final processed = it.accountBalance.account.code == account.code;
              if (!processed) return it;
              return it.copyWith(
                status: WalletStatus.idle,
              );
            }).toList(),
            notice: WalletNotice.updateFailed(account: account, exception: exc),
          ),
        );
      },
    );
  }
}
