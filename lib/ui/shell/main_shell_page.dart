import 'package:flutter/material.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/theme.dart';

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
    return Scaffold(
      body: child,
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
            icon: const Icon(Icons.wallet_rounded),
            label: context.l10n.mainShellWalletsLabel,
          ),
          NavigationDestination(
            icon: const Icon(Icons.notes_rounded),
            label: context.l10n.mainShellTransactionsLabel,
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
