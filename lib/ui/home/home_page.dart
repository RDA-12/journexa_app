import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journexa_app/di.dart';
import 'package:journexa_app/shared/app_clock.dart';
import 'package:journexa_app/ui/home/bloc/home_bloc.dart';
import 'package:journexa_app/ui/home/widgets/home_transactions_list.dart';
import 'package:journexa_app/ui/home/widgets/mtd_section.dart';
import 'package:journexa_app/ui/home/widgets/wallets_home_carousel.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/theme.dart';

/// Page that show when user is logged in
class HomePage extends StatelessWidget with AppClockMixin {
  /// Creates new [HomePage]
  const HomePage({
    this.homeBloc,
    super.key,
  });

  /// [HomeBloc] to be provided to widget tree.
  ///
  /// Creates new one if null.
  final HomeBloc? homeBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => (homeBloc ?? getIt<HomeBloc>())
        ..add(const HomeEvent.walletsSubscriptionRequested())
        ..add(
          HomeEvent.mtdSubscriptionRequested(targetDate: getCurrentDateTime()),
        )
        ..add(const HomeEvent.transactionsSubscriptionRequested()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget with AppClockMixin {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          spacing: 24,
          children: [
            WalletsHomeCarousel(
              onChanged: (index, wallet) {
                context.read<HomeBloc>().add(
                  HomeEvent.mtdSubscriptionRequested(
                    targetDate: getCurrentDateTime(),
                    wallet: wallet,
                  ),
                );
                context.read<HomeBloc>().add(
                  HomeEvent.transactionsSubscriptionRequested(
                    wallet: wallet,
                  ),
                );
              },
            ),
            Column(
              spacing: 16,
              children: [
                Text(
                  context.l10n.homeMTDTitle,
                  style: context.text.titleMedium,
                ),
                const MTDSection(),
              ],
            ),
            Column(
              spacing: 16,
              children: [
                Text(
                  context.l10n.homeTransactionsListTitle,
                  style: context.text.titleMedium,
                ),
                const HomeTransactionsList(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
