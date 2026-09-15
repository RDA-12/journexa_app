import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journexa_app/di.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/app_responsive.dart';
import 'package:journexa_app/ui/wallets/bloc/add_wallet_bloc.dart';
import 'package:journexa_app/ui/wallets/widgets/add_wallet_view.dart';

/// Page to add new wallet
class AddWalletPage extends StatelessWidget {
  /// Creates new [AddWalletPage]
  const new({super.key, this.addWalletBloc});

  /// [AddWalletBloc] to be provided in widget tree.
  ///
  /// If null, it creates new one.
  final AddWalletBloc? addWalletBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => addWalletBloc ?? getIt<AddWalletBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.addWalletTitle),
        ),
        body: Padding(
          padding: context.pagePadding,
          child: const AddWalletView(),
        ),
      ),
    );
  }
}
