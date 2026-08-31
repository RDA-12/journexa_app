import 'package:flutter/material.dart';
import 'package:journexa_app/ui/shared/theme.dart';

/// Extension that provide bottom sheet utility methods
extension AppBottomSheetX on BuildContext {
  /// Shows modal bottom sheet
  Future<T?> showBottomModal<T>({
    required Widget Function(BuildContext) builder,
  }) {
    return showModalBottomSheet<T>(
      context: this,
      constraints: const BoxConstraints(maxWidth: 640, minHeight: 256),
      elevation: 1,
      showDragHandle: true,
      backgroundColor: color.surfaceContainerLow,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: builder(context),
        );
      },
    );
  }
}
