import 'package:bloc/bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/use_cases/journal/watch_current_balance.dart';
import 'package:journexa_app/domain/use_cases/wallet/watch_wallets.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';
import 'package:rxdart/rxdart.dart';

part 'home_event.dart';
part 'home_state.dart';
part 'home_bloc.freezed.dart';

/// Bloc to manage Home page
class HomeBloc extends Bloc<HomeEvent, HomeState> with Loggable, GenerateUid {
  /// Creates new [HomeBloc]
  HomeBloc({
    required this._watchWallets,
    required this._watchCurrentBalance,
  }) : super(const HomeState()) {
    on<_SubscriptionsRequested>(
      (event, emit) => _onSubscriptionRequested(emit: emit),
    );
  }

  final WatchWalletsUseCase _watchWallets;
  final WatchCurrentBalanceUseCase _watchCurrentBalance;

  @override
  String get logTag => 'HomeBloc';

  Future<void> _onSubscriptionRequested({
    required Emitter<HomeState> emit,
  }) async {
    final traceId = generateUid();
    logInfo(
      'Starts subscribe to required streams. '
      'Emit loading state',
      traceId: traceId,
    );
    emit(
      state.copyWith(
        wallets: const HomeWalletsUIModel(
          status: HomeUIStatus.loading,
        ),
      ),
    );

    final walletsStream = CombineLatestStream.combine2(
      _watchWallets.execute(const WatchWalletsParams(), traceId: traceId),
      _watchCurrentBalance.execute(traceId: traceId),
      (walletsRes, balanceRes) {
        logInfo('New data received', traceId: traceId);
        final balanceExc = balanceRes.errorOrNull;
        if (balanceExc != null) {
          logInfo('Balance stream emits failure', traceId: traceId);
          return AppResult<List<HomeWalletUIModel>>.failure(balanceExc);
        }

        final balances = balanceRes.valueOrNull!;
        final walletsExc = walletsRes.errorOrNull;
        if (walletsExc != null) {
          logInfo('Wallets stream emits failure', traceId: traceId);
          return AppResult<List<HomeWalletUIModel>>.failure(walletsExc);
        }

        final wallets = walletsRes.valueOrNull!;
        final uiWallets = <HomeWalletUIModel>[];
        for (final wallet in wallets) {
          uiWallets.add(
            HomeWalletUIModel(
              wallet: wallet,
              balance: balances[wallet.account.code] ?? Decimal.zero,
            ),
          );
        }

        logInfo('All streams fine', traceId: traceId);
        return AppResult<List<HomeWalletUIModel>>.success(uiWallets);
      },
    );

    await emit.forEach(
      walletsStream,
      onData: (result) {
        return result.when(
          success: (wallets) {
            logInfo('Wallets UI model received', traceId: traceId);
            return state.copyWith(
              wallets: state.wallets.copyWith(
                wallets: wallets,
                status: HomeUIStatus.loaded,
              ),
            );
          },
          failure: (exc) {
            logError('Error received from streams', traceId: traceId);
            return state.copyWith(
              wallets: state.wallets.copyWith(
                exception: exc,
                status: HomeUIStatus.failure,
              ),
            );
          },
        );
      },
    );
  }
}
