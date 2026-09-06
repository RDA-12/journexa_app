import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/ui/home/widgets/wallet_home_card.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';
import 'package:journexa_app/ui/wallets/bloc/wallets_bloc.dart';

/// Creates new [CarouselView] to shows
/// wallets data
class WalletsHomeCarousel extends StatelessWidget {
  /// Creates new [WalletsHomeCarousel]
  ///
  /// It reacts to [WalletsBloc]'s state changes.
  /// So, make sure to provide that within the
  /// widget tree.
  const WalletsHomeCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    final height = context.screenHeight;
    final maxHeight = min<double>(height / 2, 320);

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: BlocBuilder<WalletsBloc, WalletsState>(
        buildWhen: (p, c) =>
            p.status == WalletsUIStatus.loading ||
            c.status == WalletsUIStatus.loading,
        builder: (context, state) {
          if (state.status == WalletsUIStatus.loading) {
            return Center(
              child: LoadingIndicator(
                semanticsLabel: context.l10n.homeWalletsLoadingSemantics,
              ),
            );
          }

          if (state.status == WalletsUIStatus.failure) {
            return Center(
              child: AppExceptionBox(
                title: context.l10n.homeWalletsFailureTitle,
                description:
                    (state.exception?.code ??
                            AppExceptionCode.internalException)
                        .toLocalizedString(context),
              ),
            );
          }

          final wallets = state.wallets;
          if (wallets.isEmpty) {
            return Center(
              child: AppEmptyBox(
                description: context.l10n.homeWalletsEmptyDescription,
              ),
            );
          }

          final totalBalance = wallets
              .map((it) => it.balance)
              .reduce((prev, curr) => prev + curr);
          return CarouselView.weightedBuilder(
            itemCount: wallets.length + 1,
            flexWeights: const [1, 5, 1],
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
