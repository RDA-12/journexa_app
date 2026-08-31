import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/ui/shared/widgets/app_selector.dart';
import 'package:journexa_app/ui/wallets/bloc/wallets_bloc.dart';

/// Creates new [AppSelector] to select a [Wallet]
class WalletSelector extends StatefulWidget {
  /// Creates new [WalletSelector]
  ///
  /// It uses [WalletsBloc] to search and fetch wallets.
  /// So, make sure to provide it with that bloc.
  const WalletSelector({
    required this.isRequired,
    this.label,
    this.initialItems = const [],
    this.controller,
    this.initialValue,
    super.key,
  });

  /// Whether this wallet selector is required
  final bool isRequired;

  /// Optional label for this wallet selector
  final String? label;

  /// Optional controller for this wallet selector
  ///
  /// Creates new one when null
  final AppSelectorController<Wallet>? controller;

  /// Initial items to display in the wallet selector
  ///
  /// Defaults to an empty list
  final List<Wallet> initialItems;

  /// Initial value to be selected
  final Wallet? initialValue;

  @override
  State<WalletSelector> createState() => _WalletSelectorState();
}

class _WalletSelectorState extends State<WalletSelector> {
  late final AppSelectorController<Wallet> _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ??
        AppSelectorController<Wallet>(
          displayAsString: (it) => it.name,
        );
    if (widget.initialItems.isNotEmpty) {
      _controller.items = widget.initialItems;
    }
    if (widget.initialValue != null) {
      _controller.value = widget.initialValue;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WalletsBloc, WalletsState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        switch (state.status) {
          case WalletsStatus.loading:
            _controller.isLoading = true;
          case WalletsStatus.failure:
            _controller.lastError = state.exception;
          case WalletsStatus.loaded:
            _controller.isLoading = false;
            _controller.items = state.walletWithBalances
                .map((it) => it.walletWithBalance.wallet)
                .toList();
          case _:
        }
      },
      child: AppSelector(
        controller: _controller,
        isRequired: widget.isRequired,
        label: widget.label,
        onPressed: () {
          context.read<WalletsBloc>().add(const WalletsEvent.load());
        },
        onSearch: (query) {
          context.read<WalletsBloc>().add(
            WalletsEvent.search(query: query),
          );
        },
      ),
    );
  }
}
