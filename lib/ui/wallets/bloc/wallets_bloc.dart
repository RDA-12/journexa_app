import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/use_cases/wallet/delete_wallet.dart';
import 'package:journexa_app/domain/use_cases/wallet/get_all_wallets.dart';
import 'package:journexa_app/domain/use_cases/wallet/update_wallet.dart';
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
    required this._deleteWallet,
    required this._updateWallet,
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
        return _onDelete(wallet: event.wallet, emit: emit);
      },
    );
    on<_Update>(
      (event, emit) async {
        return _onUpdate(
          wallet: event.wallet,
          emit: emit,
          name: event.name,
        );
      },
    );
  }

  @override
  String get logTag => 'WalletsBloc';

  final GetAllWalletsUseCase _getAllWallets;
  final DeleteWalletUseCase _deleteWallet;
  final UpdateWalletUseCase _updateWallet;

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
      success: (walletWithBalances) {
        logInfo(
          'Get wallets succeeded. Emit loaded status',
          traceId: traceId,
        );
        emit(
          state.copyWith(
            status: WalletsStatus.loaded,
            walletWithBalances: walletWithBalances
                .map((it) => WalletWithBalanceState(walletWithBalance: it))
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
    required Wallet wallet,
    required Emitter<WalletsState> emit,
  }) async {
    final traceId = generateUid();
    final walletIdx = state.walletWithBalances.indexWhere(
      (it) => it.walletWithBalance.wallet.id == wallet.id,
    );
    if (walletIdx == -1) {
      logInfo(
        'Wallet with id ${wallet.id} not found in walletWithBalances. '
        'Early return',
        traceId: traceId,
      );
      return;
    }

    logInfo(
      'Starts deleting wallet with id ${wallet.id}. '
      'Emit new walletWithBalances with status deleting on the Wallet',
      traceId: traceId,
    );
    emit(
      state.copyWith(
        walletWithBalances: state.walletWithBalances.map((it) {
          final isDeleting = it.walletWithBalance.wallet.id == wallet.id;
          if (!isDeleting) return it;
          return it.copyWith(status: WalletStatus.deleting);
        }).toList(),
      ),
    );
    final result = await _deleteWallet.execute(
      DeleteWalletParams(wallet: wallet),
      traceId: traceId,
    );
    result.when(
      success: (_) {
        logInfo(
          'Deletes wallet success. '
          'Filter wallet from walletWithBalances. '
          'Emit with recentlyDeleted notice',
          traceId: traceId,
        );
        emit(
          state.copyWith(
            status: WalletsStatus.loaded,
            walletWithBalances: state.walletWithBalances
                .where((it) => it.walletWithBalance.wallet.id != wallet.id)
                .toList(),
            notice: WalletNotice.recentlyDeleted(wallet: wallet),
          ),
        );
      },
      failure: (exc) {
        logInfo(
          'Delete wallet failed. '
          'Emit idle status on the Wallet with deleteFailed notice',
          traceId: traceId,
        );
        emit(
          state.copyWith(
            status: WalletsStatus.loaded,
            walletWithBalances: state.walletWithBalances.map((it) {
              final processed = it.walletWithBalance.wallet.id == wallet.id;
              if (!processed) return it;
              return it.copyWith(status: WalletStatus.idle);
            }).toList(),
            notice: WalletNotice.deleteFailed(
              wallet: wallet,
              exception: exc,
            ),
          ),
        );
      },
    );
  }

  Future<void> _onUpdate({
    required Wallet wallet,
    required Emitter<WalletsState> emit,
    String? name,
  }) async {
    final traceId = generateUid();
    logInfo('Checking wallet with id ${wallet.id}', traceId: traceId);
    final walletIdx = state.walletWithBalances.indexWhere(
      (it) => it.walletWithBalance.wallet.id == wallet.id,
    );
    if (walletIdx == -1) {
      logInfo('Wallet not found. Skipping', traceId: traceId);
      return;
    }
    final oldWallet =
        state.walletWithBalances[walletIdx].walletWithBalance.wallet;

    logInfo(
      'Starts updating wallet ${wallet.id}. '
      'Emit new walletWithBalances with status updateing on the Wallet',
      traceId: traceId,
    );
    emit(
      state.copyWith(
        walletWithBalances: state.walletWithBalances.map((it) {
          final isUpdating = it.walletWithBalance.wallet.id == wallet.id;
          if (!isUpdating) return it;
          return it.copyWith(status: WalletStatus.updating);
        }).toList(),
      ),
    );

    final params = UpdateWalletParams(
      wallet: wallet,
      name: name,
    );
    final result = await _updateWallet.execute(params, traceId: traceId);
    result.when(
      success: (updated) {
        logInfo(
          'Updates wallet success. '
          'Emit updated wallet with idle status and recentlyUpdated notice',
          traceId: traceId,
        );
        emit(
          state.copyWith(
            status: WalletsStatus.loaded,
            walletWithBalances: state.walletWithBalances.map((it) {
              final processed = it.walletWithBalance.wallet.id == wallet.id;
              if (!processed) return it;
              return it.copyWith(
                status: WalletStatus.idle,
                walletWithBalance: it.walletWithBalance.copyWith(
                  wallet: updated,
                ),
              );
            }).toList(),
            notice: WalletNotice.recentlyUpdated(
              from: oldWallet,
              to: updated,
            ),
          ),
        );
      },
      failure: (exc) {
        logInfo(
          'Update wallet failed. '
          'Emit idel status on the Wallet and updateFailed notice',
          traceId: traceId,
        );
        emit(
          state.copyWith(
            status: WalletsStatus.loaded,
            walletWithBalances: state.walletWithBalances.map((it) {
              final processed = it.walletWithBalance.wallet.id == wallet.id;
              if (!processed) return it;
              return it.copyWith(
                status: WalletStatus.idle,
              );
            }).toList(),
            notice: WalletNotice.updateFailed(wallet: wallet, exception: exc),
          ),
        );
      },
    );
  }
}
