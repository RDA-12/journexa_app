import 'package:bloc/bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/use_cases/journal/watch_current_balance.dart';
import 'package:journexa_app/domain/use_cases/wallet/delete_wallet.dart';
import 'package:journexa_app/domain/use_cases/wallet/update_wallet.dart';
import 'package:journexa_app/domain/use_cases/wallet/watch_wallets.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';
import 'package:journexa_app/ui/shared/event_transform/debounce.dart';
import 'package:rxdart/rxdart.dart';

part 'wallets_bloc.freezed.dart';
part 'wallets_event.dart';
part 'wallets_state.dart';

/// Bloc to get all wallets current user have
@injectable
class WalletsBloc extends Bloc<WalletsEvent, WalletsState>
    with GenerateUid, Loggable {
  /// Creates new [WalletsBloc]
  new({
    required this._watchWallets,
    required this._watchAccountBalances,
    required this._deleteWallet,
    required this._updateWallet,
  }) : super(const WalletsState()) {
    on<_SubscriptionRequested>(
      (event, emit) async {
        return await _onSubscriptionRequested(
          emit: emit,
          params: WatchWalletsParams(query: event.query),
        );
      },
      transformer: debounce(),
    );
    on<_Delete>(
      (event, emit) async {
        return await _onDelete(wallet: event.wallet, emit: emit);
      },
    );
    on<_Update>(
      (event, emit) async {
        return await _onUpdate(
          wallet: event.wallet,
          emit: emit,
          name: event.name,
        );
      },
    );
  }

  @override
  String get logTag => 'WalletsBloc';

  final WatchWalletsUseCase _watchWallets;
  final WatchCurrentBalanceUseCase _watchAccountBalances;
  final DeleteWalletUseCase _deleteWallet;
  final UpdateWalletUseCase _updateWallet;

  Future<void> _onSubscriptionRequested({
    required Emitter<WalletsState> emit,
    required WatchWalletsParams params,
  }) async {
    final traceId = generateUid();
    logInfo(
      'Starts listening to Wallet streams. '
      'Emits loading state',
      traceId: traceId,
    );
    emit(
      const WalletsState(
        status: WalletsUIStatus.loading,
      ),
    );

    final stream = CombineLatestStream.combine2(
      _watchWallets.execute(params, traceId: traceId),
      _watchAccountBalances.execute(traceId: traceId),
      (walletsRes, currentBalanceRes) {
        logInfo('New data recevied', traceId: traceId);
        final currentBalancesExc = currentBalanceRes.errorOrNull;
        if (currentBalancesExc != null) {
          logInfo('Current balance stream emits failure', traceId: traceId);
          return AppResult<List<WalletUIModel>>.failure(currentBalancesExc);
        }

        final walletsExc = walletsRes.errorOrNull;
        if (walletsExc != null) {
          logInfo('Wallets stream emits failure', traceId: traceId);
          return AppResult<List<WalletUIModel>>.failure(walletsExc);
        }

        final currentBalances = currentBalanceRes.valueOrNull!;
        final wallets = walletsRes.valueOrNull!;
        final result = <WalletUIModel>[];
        for (final wallet in wallets) {
          final balance = currentBalances[wallet.account.code.value];
          result.add(
            WalletUIModel(
              wallet: wallet,
              balance: balance ?? Decimal.zero,
            ),
          );
        }
        logInfo('All Streams fine', traceId: traceId);
        return AppResult.success(result);
      },
    );
    await emit.forEach(
      stream,
      onData: (result) {
        return result.when(
          success: (wallets) {
            final currentItemState = {
              for (final it in state.wallets) it.wallet.id: it.status,
            };
            logInfo(
              'Streamed wallets succeeded. Emit loaded status',
              traceId: traceId,
            );
            return state.copyWith(
              status: WalletsUIStatus.loaded,
              wallets: wallets
                  .map(
                    (it) => WalletUIModel(
                      wallet: it.wallet,
                      balance: it.balance,
                      status:
                          currentItemState[it.wallet.id] ?? WalletUIStatus.idle,
                    ),
                  )
                  .toList(),
            );
          },
          failure: (exc) {
            logInfo(
              'Streamed wallets failed. Emit failure status',
              traceId: traceId,
            );
            return state.copyWith(
              status: WalletsUIStatus.failure,
              exception: exc,
            );
          },
        );
      },
    );
  }

  Future<void> _onDelete({
    required Wallet wallet,
    required Emitter<WalletsState> emit,
  }) async {
    final traceId = generateUid();
    final walletIdx = state.wallets.indexWhere(
      (it) => it.wallet.id == wallet.id,
    );
    if (walletIdx == -1) {
      logInfo(
        'Wallet with id ${wallet.id} not found in wallets. '
        'Early return',
        traceId: traceId,
      );
      return;
    }

    logInfo(
      'Starts deleting wallet with id ${wallet.id}. '
      'Emit new wallets with status deleting on the Wallet',
      traceId: traceId,
    );
    emit(
      state.copyWith(
        wallets: state.wallets.map((it) {
          final isDeleting = it.wallet.id == wallet.id;
          if (!isDeleting) return it;
          return it.copyWith(status: WalletUIStatus.deleting);
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
          'Filter wallet from wallets. '
          'Emit with recentlyDeleted notice',
          traceId: traceId,
        );
        emit(
          state.copyWith(
            status: WalletsUIStatus.loaded,
            notice: WalletUINotice.recentlyDeleted(wallet: wallet),
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
            status: WalletsUIStatus.loaded,
            wallets: state.wallets.map((it) {
              final processed = it.wallet.id == wallet.id;
              if (!processed) return it;
              return it.copyWith(status: WalletUIStatus.idle);
            }).toList(),
            notice: WalletUINotice.deleteFailed(
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
    final walletIdx = state.wallets.indexWhere(
      (it) => it.wallet.id == wallet.id,
    );
    if (walletIdx == -1) {
      logInfo('Wallet not found. Skipping', traceId: traceId);
      return;
    }
    final oldWallet = state.wallets[walletIdx].wallet;

    logInfo(
      'Starts updating wallet ${wallet.id}. '
      'Emit new wallets with status updateing on the Wallet',
      traceId: traceId,
    );
    emit(
      state.copyWith(
        wallets: state.wallets.map((it) {
          final isUpdating = it.wallet.id == wallet.id;
          if (!isUpdating) return it;
          return it.copyWith(status: WalletUIStatus.updating);
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
            status: WalletsUIStatus.loaded,
            notice: WalletUINotice.recentlyUpdated(
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
            status: WalletsUIStatus.loaded,
            wallets: state.wallets.map((it) {
              final processed = it.wallet.id == wallet.id;
              if (!processed) return it;
              return it.copyWith(
                status: WalletUIStatus.idle,
              );
            }).toList(),
            notice: WalletUINotice.updateFailed(wallet: wallet, exception: exc),
          ),
        );
      },
    );
  }
}
