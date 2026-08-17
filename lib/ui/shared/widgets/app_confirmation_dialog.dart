import 'package:flutter/material.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/theme.dart';
import 'package:journexa_app/ui/shared/widgets/app_button.dart';

/// [Widget] that intended to be showed within a Dialog
class AppConfirmationDialog extends StatelessWidget {
  /// Creates new [AppConfirmationDialog]
  const AppConfirmationDialog({
    required this.title,
    required this.content,
    this.confirmLabel,
    this.cancelLabel,
    this.onConfirmPressed,
    this.onCancelPressed,
    super.key,
  });

  /// Shows [AppConfirmationDialog] with [showDialog]
  ///
  /// Dialog will be auto closed after user
  /// pressing confirm or cancel button.
  ///
  /// True when [onConfirmPressed] is executed
  /// False when [onCancelPressed] is executed
  /// Null when dialog is popped out without any action
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String content,
    String? confirmLabel,
    String? cancelLabel,
  }) async {
    final result = await showDialog<bool?>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          child: AppConfirmationDialog(
            title: title,
            content: content,
            confirmLabel: confirmLabel,
            cancelLabel: cancelLabel,
            onConfirmPressed: () {
              Navigator.of(context).pop(true);
            },
            onCancelPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        );
      },
    );
    return result ?? false;
  }

  /// Title to be showed
  final String title;

  /// Content to be showed
  final String content;

  /// Label for confirm button
  final String? confirmLabel;

  /// Label for cancel button
  final String? cancelLabel;

  /// Callback to be called when confirm button is pressed
  final VoidCallback? onConfirmPressed;

  /// Callback to be called when cancel button is pressed
  final VoidCallback? onCancelPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 560),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.color.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        spacing: 24,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            spacing: 16,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: context.text.headlineSmall,
                ),
              ),
              Text(
                content,
                style: context.text.bodyMedium?.copyWith(
                  color: context.color.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Row(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton(
                label: cancelLabel ?? context.l10n.commonCancelLabel,
                onPressed: onCancelPressed,
                type: ButtonType.text,
              ),
              AppButton(
                label: confirmLabel ?? context.l10n.commonConfirmLabel,
                onPressed: onConfirmPressed,
                type: ButtonType.text,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
