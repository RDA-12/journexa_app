import 'package:flutter/material.dart';

/// Creates new [OutlinedButton] if only label is provided.
/// Creates new [OutlinedButton.icon] if both label and icon are provided.
class AppOutlinedButton extends StatelessWidget {
  /// Creates new [AppOutlinedButton]
  const AppOutlinedButton({
    required this.onPressed,
    required this.label,
    this.icon,
    super.key,
  });

  /// Label for the Button
  final String label;

  /// Icon for the Button
  ///
  /// Icon will be rendered on the left of [label] if both are provided
  final Widget? icon;

  /// Function to be called when the button is pressed
  ///
  /// If null, the button will be disabled
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        label: Text(label),
        icon: SizedBox.square(dimension: 24, child: icon),
        iconAlignment: IconAlignment.start,
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
