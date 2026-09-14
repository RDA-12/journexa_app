import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/ui/home/bloc/home_bloc.dart';
import 'package:journexa_app/ui/home/widgets/wallet_home_card.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';

/// Creates new [CarouselView] to shows
/// wallets data
class WalletsHomeCarousel extends StatelessWidget {
  /// Creates new [WalletsHomeCarousel]
  ///
  /// It reacts to [HomeBloc]'s wallet state changes.
  /// So, make sure to provide that within the
  /// widget tree.
  const WalletsHomeCarousel({super.key, this.onChanged});

  /// A Callback invoked when wallet changed. It has index and Wallet.
  ///
  /// The Wallet is only null index is 0. That means,
  /// it currently shows total balance
  final void Function(int, Wallet?)? onChanged;

  @override
  Widget build(BuildContext context) {
    final height = context.screenHeight;
    final maxHeight = min<double>(height / 2, 320);

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (p, c) =>
            p.wallets.status == HomeUIStatus.loading ||
            c.wallets.status == HomeUIStatus.loading,
        builder: (context, state) {
          final walletsState = state.wallets;
          if (walletsState.status == HomeUIStatus.loading) {
            return Center(
              child: LoadingIndicator(
                semanticsLabel: context.l10n.homeWalletsLoadingSemantics,
              ),
            );
          }

          if (walletsState.status == HomeUIStatus.failure) {
            return Center(
              child: AppExceptionBox(
                title: context.l10n.homeWalletsFailureTitle,
                description:
                    (walletsState.exception?.code ??
                            AppExceptionCode.internalException)
                        .toLocalizedString(context),
              ),
            );
          }

          final wallets = walletsState.wallets;
          if (wallets.isEmpty) {
            return Center(
              child: AppEmptyBox(
                description: context.l10n.homeWalletsEmptyDescription,
              ),
            );
          }
          if (wallets.length == 1) {
            final walletData = wallets.first;
            return WalletHomeCard(
              name: walletData.wallet.name,
              balance: walletData.balance,
            );
          }

          final totalBalance = wallets
              .map((it) => it.balance)
              .reduce((prev, curr) => prev + curr);
          return CarouselView.weightedBuilder(
            itemCount: wallets.length + 1,
            flexWeights: const [1, 5, 1],
            onIndexChanged: (index) {
              if (index == 0) {
                onChanged?.call(index, null);
              } else {
                onChanged?.call(index, wallets[index - 1].wallet);
              }
            },
            itemBuilder: (context, index) {
              if (index == 0) {
                return WalletHomeCard(
                  name: context.l10n.homeWalletsTotalBalanceLabel,
                  balance: totalBalance,
                );
              }

              final walletData = wallets[index - 1];
              return WalletHomeCard(
                name: walletData.wallet.name,
                balance: walletData.balance,
              );
            },
          );
        },
      ),
    );
  }
}
