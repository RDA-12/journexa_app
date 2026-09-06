import 'package:flutter/widgets.dart';

/// Breakpoint definition
/// based on material 3 breakpoints
/// https://m3.material.io/foundations/layout/breakpoints/overview
enum BreakPoint {
  /// Compact (smaller than 600)
  compact,

  /// Medium (600 <= medium < 840)
  medium,

  /// Expanded (840 <= expanded < 1200)
  expanded,

  /// Large (1200 <= large < 1600)
  large,

  /// Extra Large (1600 <= xLarge)
  xLarge;

  /// Return the maximum width of this breakpoint
  double get maxWidth {
    switch (this) {
      case BreakPoint.compact:
        return 600;
      case BreakPoint.medium:
        return 840;
      case BreakPoint.expanded:
        return 1200;
      case BreakPoint.large:
        return 1600;
      case BreakPoint.xLarge:
        return double.infinity;
    }
  }
}

/// Extension to helps get device size
extension SizeX on BuildContext {
  /// Return [Size] of current device
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Return screen width of current device
  double get screenWidth => screenSize.width;

  /// Return screen height of current device
  double get screenHeight => screenSize.height;
}

/// Extension to helps get spacing based on
/// device size
extension SpaceX on BuildContext {
  /// Return [EdgeInsets] for page padding
  /// based on device size
  EdgeInsets get pagePadding {
    if (screenWidth < BreakPoint.compact.maxWidth) {
      return const EdgeInsets.all(16);
    }

    if (screenWidth < BreakPoint.medium.maxWidth) {
      return const EdgeInsets.all(24);
    }

    return const EdgeInsets.all(32);
  }
}
