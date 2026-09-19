import 'package:flutter/material.dart';
import 'package:journexa_app/ui/shared/theme.dart';

/// Creates FAB to be showed as action within expandable fab
class AppFabAction extends StatelessWidget {
  /// Creates new [AppFabAction]
  const new({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.semanticsLabel,
    super.key,
  });

  /// Label for this action
  final String label;

  /// Icon for this action
  final Widget icon;

  /// Semantics label for this action.
  ///
  /// If null, use [label] instead
  final String? semanticsLabel;

  /// Callback when action is pressed
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: null,
      backgroundColor: context.color.primaryContainer,
      foregroundColor: context.color.onPrimaryContainer,
      onPressed: onPressed,
      label: Text(
        label,
        semanticsLabel: semanticsLabel,
      ),
      icon: icon,
    );
  }
}
