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

  @override
  Widget build(BuildContext context) {
    return Card(
      borderOnForeground: false,
      color: context.color.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(24),
        side: BorderSide(
          color: context.color.outlineVariant,
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
