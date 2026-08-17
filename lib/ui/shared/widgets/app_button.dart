import 'package:flutter/material.dart';
import 'package:journexa_app/ui/shared/theme.dart';

/// Button sizes for [AppButton]
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

/// Color types for [AppButton]
enum ButtonColorType {
  /// Normal color type
  normal,

  /// Danger color type
  danger;

  /// Returns [Color] of foreground for this type
  Color foreground(BuildContext context, ButtonType type) {
    return switch (type) {
      ButtonType.filled => switch (this) {
        ButtonColorType.normal => context.color.onPrimary,
        ButtonColorType.danger => context.color.onError,
      },
      ButtonType.outlined => switch (this) {
        ButtonColorType.normal => context.color.onSurfaceVariant,
        ButtonColorType.danger => context.color.error,
      },
    };
  }

  /// Returns [Color] of background for this type
  Color background(BuildContext context, ButtonType type) {
    return switch (type) {
      ButtonType.filled => switch (this) {
        ButtonColorType.normal => context.color.primary,
        ButtonColorType.danger => context.color.error,
      },
      ButtonType.outlined => Colors.transparent,
    };
  }

  /// Return [Color] of border for this type
  Color? border(BuildContext context, ButtonType type) {
    return switch (type) {
      ButtonType.filled => null,
      ButtonType.outlined => switch (this) {
        ButtonColorType.normal => context.color.primary,
        ButtonColorType.danger => context.color.error,
      },
    };
  }
}

/// Button types for [AppButton]
enum ButtonType {
  /// Outlined type, default
  outlined,

  /// Filled type
  filled;

  /// Returns [ButtonStyle] for this type
  ButtonStyle style(
    BuildContext context,
    ButtonSize size,
    ButtonColorType color,
  ) => switch (this) {
    ButtonType.outlined => OutlinedButton.styleFrom(
      minimumSize: size.minimumSize,
      textStyle: size.textStyle(context),
      padding: size.padding,
      backgroundColor: color.background(context, this),
      foregroundColor: color.foreground(context, this),
      side: BorderSide(color: color.border(context, this)!),
    ),
    ButtonType.filled => FilledButton.styleFrom(
      minimumSize: size.minimumSize,
      textStyle: size.textStyle(context),
      padding: size.padding,
      backgroundColor: color.background(context, this),
      foregroundColor: color.foreground(context, this),
    ),
  };
}

/// Conditionally creates [FilledButton] or [OutlinedButton] based on [type]
///
/// If [icon] provided, use [FilledButton.icon] or [OutlinedButton.icon].
class AppButton extends StatelessWidget {
  /// Creates new [AppButton]
  const AppButton({
    required this.onPressed,
    required this.label,
    this.type = ButtonType.outlined,
    this.size = ButtonSize.small,
    this.color = ButtonColorType.normal,
    this.icon,
    super.key,
  });

  /// Size of the Button
  final ButtonSize size;

  /// Type of the Button
  final ButtonType type;

  /// Color of the Button
  final ButtonColorType color;

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
    if (type == ButtonType.filled) {
      if (icon != null) {
        return FilledButton.icon(
          onPressed: onPressed,
          label: Text(label),
          icon: SizedBox.square(dimension: size.iconSize, child: icon),
          iconAlignment: IconAlignment.start,
          style: type.style(context, size, color),
        );
      }

      return FilledButton(
        onPressed: onPressed,
        style: type.style(context, size, color),
        child: Text(label),
      );
    }

    if (icon != null) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        label: Text(label),
        icon: SizedBox.square(dimension: size.iconSize, child: icon),
        iconAlignment: IconAlignment.start,
        style: type.style(context, size, color),
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: type.style(context, size, color),
      child: Text(label),
    );
  }
}
