import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:journexa_app/ui/router/app_router.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/theme.dart';
import 'package:journexa_app/ui/shell/widgets/widgets.dart';

/// Shell for main page.
///
/// It consists of home, wallets, transactions, and settings
class MainShellPage extends StatelessWidget {
  /// Creates new [MainShellPage]
  const new({
    required this.currentIndex,
    required this.onDestinationChanged,
    required this.child,
    super.key,
  });

  /// Current active index
  final int currentIndex;

  /// Callback invoked when destination changed
  final void Function(int) onDestinationChanged;

  /// Widget that will be showed
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final transactionsLocation = const TransactionsListRoute().location;
    final showsFab = currentIndex < 2;

    return Scaffold(
      body: child,
      floatingActionButtonLocation: AppExpandableFab.location,
      floatingActionButton: showsFab
          ? AppExpandableFab(
              icon: const Icon(Icons.add_rounded),
              actions: [
                AppFabAction(
                  label: context.l10n.incomeTransactionTypeLabel,
                  semanticsLabel: context.l10n.mainShellAddIncomeSemanticsLabel,
                  icon: const Icon(Icons.call_received_rounded),
                  onPressed: () async {
                    final addLocation = const AddTransactionRoute(
                      TransactionType.income,
                    ).subLocation;
                    context.go('$transactionsLocation/$addLocation');
                  },
                ),
                AppFabAction(
                  label: context.l10n.expenseTransactionTypeLabel,
                  semanticsLabel:
                      context.l10n.mainShellAddExpenseSemanticsLabel,
                  icon: const Icon(Icons.call_made_rounded),
                  onPressed: () async {
                    final addLocation = const AddTransactionRoute(
                      TransactionType.expense,
                    ).subLocation;
                    context.go('$transactionsLocation/$addLocation');
                  },
                ),
                AppFabAction(
                  label: context.l10n.transferTransactionTypeLabel,
                  semanticsLabel:
                      context.l10n.mainShellAddTransferSemanticsLabel,
                  icon: const Icon(Icons.swap_vert_rounded),
                  onPressed: () async {
                    final addLocation = const AddTransactionRoute(
                      TransactionType.transfer,
                    ).subLocation;
                    context.go('$transactionsLocation/$addLocation');
                  },
                ),
              ],
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onDestinationChanged,
        indicatorColor: context.color.primaryContainer,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_rounded),
            label: context.l10n.mainShellHomeLabel,
          ),
          NavigationDestination(
            icon: const Icon(Icons.notes_rounded),
            label: context.l10n.mainShellTransactionsLabel,
          ),
          NavigationDestination(
            icon: const Icon(Icons.wallet_rounded),
            label: context.l10n.mainShellWalletsLabel,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_rounded),
            label: context.l10n.mainShellSettingsLabel,
          ),
        ],
      ),
    );
  }
}
