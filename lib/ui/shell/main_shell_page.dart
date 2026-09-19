import 'package:flutter/material.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
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
    required this.onAddTransactionPressed,
    required this.child,
    super.key,
  });

  /// Current active index
  final int currentIndex;

  /// Callback invoked when destination changed
  final void Function(int) onDestinationChanged;

  /// Widget that will be showed
  final Widget child;

  /// Callback invoked when add transaction fab pressed
  final void Function(TransactionType) onAddTransactionPressed;

  @override
  Widget build(BuildContext context) {
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
                    onAddTransactionPressed(TransactionType.income);
                  },
                ),
                AppFabAction(
                  label: context.l10n.expenseTransactionTypeLabel,
                  semanticsLabel:
                      context.l10n.mainShellAddExpenseSemanticsLabel,
                  icon: const Icon(Icons.call_made_rounded),
                  onPressed: () async {
                    onAddTransactionPressed(TransactionType.expense);
                  },
                ),
                AppFabAction(
                  label: context.l10n.transferTransactionTypeLabel,
                  semanticsLabel:
                      context.l10n.mainShellAddTransferSemanticsLabel,
                  icon: const Icon(Icons.swap_vert_rounded),
                  onPressed: () async {
                    onAddTransactionPressed(TransactionType.transfer);
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
