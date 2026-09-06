import 'package:flutter/material.dart';
import 'package:journexa_app/ui/shared/theme.dart';

/// Creates new [Card] with app UI
class AppCard extends StatelessWidget {
  /// Creates new [AppCard]
  ///
  /// [leading] will be placed before [child]
  const AppCard({
    required this.child,
    this.leading,
    this.bottom,
    this.backgroundColor,
    this.borderColor,
    super.key,
  });

  /// [Widget] that will be placed before [child]
  final Widget? leading;

  /// Main [Widget] to be showed
  final Widget child;

  /// [Widget] that will be placed under [leading] and [child]
  ///
  /// Typically used for actions
  final Widget? bottom;

  /// Color for the background
  final Color? backgroundColor;

  /// Color for the border
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      borderOnForeground: false,
      color: backgroundColor ?? context.color.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(16),
        side: BorderSide(
          color: borderColor ?? context.color.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          spacing: 12,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              spacing: 16,
              children: [
                ?leading,
                Expanded(child: child),
              ],
            ),
            ?bottom,
          ],
        ),
      ),
    );
  }
}
