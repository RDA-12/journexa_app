import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:journexa_app/ui/shared/theme.dart';
import 'package:journexa_app/ui/shell/widgets/app_fab_action.dart';

/// Creates new floating action button that expand to list of actions
class AppExpandableFab extends StatelessWidget {
  /// Creates new [AppExpandableFab]
  const new({
    required this.icon,
    required this.actions,
    super.key,
  });

  /// Icon for the main FAB
  final Widget icon;

  /// Actions to be showed when FAB is expanded
  final List<AppFabAction> actions;

  /// Returns [FloatingActionButtonLocation]
  static FloatingActionButtonLocation get location => ExpandableFab.location;

  @override
  Widget build(BuildContext context) {
    return ExpandableFab(
      type: ExpandableFabType.up,
      openButtonBuilder: RotateFloatingActionButtonBuilder(
        child: const Icon(Icons.add_rounded),
        backgroundColor: context.color.primaryContainer,
        foregroundColor: context.color.onPrimaryContainer,
      ),
      closeButtonBuilder: DefaultFloatingActionButtonBuilder(
        child: const Icon(Icons.close_rounded),
        backgroundColor: context.color.primary,
        foregroundColor: context.color.onPrimary,
      ),
      distance: 4,
      children: actions,
    );
  }
}
