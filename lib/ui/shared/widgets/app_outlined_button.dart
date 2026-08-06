import 'package:flutter/material.dart';
import 'package:journexa_app/ui/shared/theme.dart';

/// Button sizes for [AppOutlinedButton]
enum ButtonSize {
  /// Small size, default
  small,

  /// Medium size
  medium;

  /// Return [Size] minimum for this size
  Size get minimumSize => switch (this) {
    ButtonSize.small => const Size(64, 40),
    ButtonSize.medium => const Size(64, 56),
  };

  /// Return [Size] of icon
  double get iconSize => switch (this) {
    ButtonSize.small => 20,
    ButtonSize.medium => 24,
  };

  /// Return [TextStyle] of this size
  TextStyle textStyle(BuildContext context) => switch (this) {
    ButtonSize.small => context.text.labelLarge!,
    ButtonSize.medium => context.text.titleMedium!,
  };

  /// Return [EdgeInsets] for padding of this size
  EdgeInsets get padding => switch (this) {
    ButtonSize.small => const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 10,
    ),
    ButtonSize.medium => const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 16,
    ),
  };
}

/// Creates new [OutlinedButton] if only label is provided.
/// Creates new [OutlinedButton.icon] if both label and icon are provided.
class AppOutlinedButton extends StatelessWidget {
  /// Creates new [AppOutlinedButton]
  const AppOutlinedButton({
    required this.onPressed,
    required this.label,
    this.size = ButtonSize.small,
    this.icon,
    super.key,
  });

  /// Size of the Button
  final ButtonSize size;

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
    final style = OutlinedButton.styleFrom(
      minimumSize: size.minimumSize,
      textStyle: size.textStyle(context),
      padding: size.padding,
    );

    if (icon != null) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        label: Text(label),
        icon: SizedBox.square(dimension: size.iconSize, child: icon),
        iconAlignment: IconAlignment.start,
        style: style,
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: style,
      child: Text(label),
    );
  }
}
