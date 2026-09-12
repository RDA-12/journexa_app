import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journexa_app/di.dart';
import 'package:journexa_app/shared/app_clock.dart';
import 'package:journexa_app/ui/home/bloc/home_bloc.dart';
import 'package:journexa_app/ui/home/widgets/wallets_home_carousel.dart';

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
        ..add(const HomeEvent.subscriptionsRequested())
        ..add(
          HomeEvent.mtdSubscriptionRequested(targetDate: getCurrentDateTime()),
        ),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            WalletsHomeCarousel(),
          ],
        ),
      ),
    );
  }
}
