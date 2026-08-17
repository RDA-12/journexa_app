import 'package:flutter/material.dart';

/// Creates new [IconButton.filled] based on [icon]
/// and set [semanticsLabel] as tooltip on the [IconButton]
class AppIconButton extends StatelessWidget {
  /// Creates new [AppIconButton]
  ///
  /// [semanticsLabel] will be set as tooltip.
  /// So, it serve as tooltip text and semantics accessibility label
  const AppIconButton({
    required this.icon,
    required this.onPressed,
    required this.semanticsLabel,
    super.key,
  });

  /// Icon to be displayed on the [IconButton]
  final Widget icon;

  /// Callback to be called when the [IconButton] is pressed
  final VoidCallback? onPressed;

  /// Semantics label for the [IconButton]
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      icon: icon,
      onPressed: onPressed,
      tooltip: semanticsLabel,
    );
  }
}
