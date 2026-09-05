import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:journexa_app/di.dart';
import 'package:journexa_app/domain/use_cases/journal/watch_current_balance.dart';
import 'package:journexa_app/domain/use_cases/wallet/delete_wallet.dart';
import 'package:journexa_app/domain/use_cases/wallet/update_wallet.dart';
import 'package:journexa_app/domain/use_cases/wallet/watch_wallets.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/app_responsive.dart';
import 'package:journexa_app/ui/wallets/bloc/wallets_bloc.dart';
import 'package:journexa_app/ui/wallets/widgets/wallets_list_view.dart';

/// Page to shows list of wallets saved by current user
class WalletsListPage extends StatelessWidget {
  /// Creates new [WalletsListPage]
  const WalletsListPage({
    this.walletsBloc,
    super.key,
  });

  /// [WalletsBloc] to be provided to widget tree.
  ///
  /// Creates new one if null.
  final WalletsBloc? walletsBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          (walletsBloc ??
                WalletsBloc(
                  watchWallets: getIt<WatchWalletsUseCase>(),
                  watchCurrentBalance: getIt<WatchCurrentBalanceUseCase>(),
                  deleteWallet: getIt<DeleteWalletUseCase>(),
                  updateWallet: getIt<UpdateWalletUseCase>(),
                ))
            ..add(const WalletsEvent.subscriptionRequested()),
      child: const _WalletListView(),
    );
  }
}

class _WalletListView extends StatelessWidget {
  const _WalletListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.walletsListTitle),
      ),
      body: Padding(
        padding: context.pagePadding,
        child: WalletsListView(
          onAddPressed: () async {
            await context.push('/add-wallet-account');
            if (!context.mounted) return;
            context.read<WalletsBloc>().add(
              const WalletsEvent.subscriptionRequested(),
            );
          },
        ),
      ),
    );
  }
}
