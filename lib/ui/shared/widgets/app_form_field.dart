import 'package:flutter/material.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/theme.dart';

/// Creates new [TextFormField] to allows users input something
class AppFormField extends StatelessWidget {
  /// Creates new [AppFormField]
  const AppFormField({
    required this.isRequired,
    this.readOnly = false,
    this.icon,
    this.label,
    this.controller,
    this.onPressed,
    super.key,
  });

  /// Whether this form is required or not
  ///
  /// If true, will check emptiness on [TextFormField]'s validator
  final bool isRequired;

  /// Whether this form is read only or not
  final bool readOnly;

  /// Widget prefix that shown before label
  final Widget? icon;

  /// Label that shown above [TextFormField]
  final String? label;

  /// [TextEditingController] that managing input value
  final TextEditingController? controller;

  /// Callback that will be invoked when the form is pressed
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    var effectiveSemanticsLabel = label;
    if (isRequired && label != null) {
      effectiveSemanticsLabel = '$label, ${context.l10n.commonRequired}';
    }

    return TextFormField(
      controller: controller,
      validator: (value) => _validator(context, value),
      readOnly: readOnly,
      onTap: onPressed,
      decoration: InputDecoration(
        fillColor: WidgetStateColor.resolveWith(
          (states) {
            if (states.contains(WidgetState.disabled)) {
              return context.color.surfaceContainerHighest;
            }
            if (states.contains(WidgetState.hovered)) {
              return context.color.surfaceContainerHigh;
            }
            return context.color.surfaceContainer;
          },
        ),
        filled: true,
        border: WidgetStateInputBorder.resolveWith(
          (states) {
            final baseBorder = OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            );
            if (states.contains(WidgetState.error)) {
              return baseBorder.copyWith(
                borderSide: BorderSide(
                  color: context.color.error,
                ),
              );
            }
            if (states.contains(WidgetState.focused)) {
              return baseBorder.copyWith(
                borderSide: BorderSide(
                  color: context.color.primary,
                ),
              );
            }
            return baseBorder;
          },
        ),
        prefixIcon: icon,
        label: label != null
            ? Text.rich(
                TextSpan(
                  text: label,
                  children: [
                    if (isRequired)
                      const TextSpan(
                        text: ' *',
                      ),
                  ],
                ),
                semanticsLabel: effectiveSemanticsLabel,
              )
            : null,
      ),
    );
  }

  String? _validator(BuildContext context, String? value) {
    if (isRequired && (value == null || value.isEmpty)) {
      return context.l10n.formErrorRequired;
    }
    return null;
  }
}
