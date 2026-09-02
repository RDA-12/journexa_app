import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:journexa_app/shared/formatter/formatter.dart';
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

/// Controller for [AppDecimalFormField]
final class AppDecimalController extends ChangeNotifier {
  /// Creates new [AppDecimalController]
  AppDecimalController({Decimal? initialValue})
    : _value = initialValue,
      _textEditingController = TextEditingController(
        text: initialValue?.toLocalizedString('en'),
      ) {
    _textEditingController.addListener(_onTextChanged);
  }

  String _languageCode = 'en';

  /// Returns current language code
  String get languageCode => _languageCode;

  /// Sets new language code
  set languageCode(String languageCode) {
    if (_languageCode != languageCode) {
      _languageCode = languageCode;
      if (_value != null) {
        _textEditingController.text = _value!.toLocalizedString(_languageCode);
      }
    }
  }

  final TextEditingController _textEditingController;

  /// Returns [TextEditingController]
  TextEditingController get textEditingController => _textEditingController;

  Decimal? _value;

  /// Returns current [Decimal] value
  Decimal? get value => _value;

  void _onTextChanged() {
    final textValue = _textEditingController.text.trim();
    final decimal = textValue.tryToDecimal(_languageCode);
    if (decimal == null) {
      _textEditingController.text = '0';
      _value = Decimal.zero;
    } else {
      _value = decimal;
      _textEditingController.text = decimal.toLocalizedString(
        _languageCode,
      );
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _textEditingController
      ..removeListener(_onTextChanged)
      ..dispose();
    super.dispose();
  }
}

/// Creates new [TextFormField] for decimal input
class AppDecimalFormField extends StatefulWidget {
  /// Creates new [AppDecimalFormField]
  const AppDecimalFormField({
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

  /// [AppDecimalController] that managing input value
  ///
  /// If null, a new controller will be created with [Decimal.zero]
  final AppDecimalController? controller;

  /// Callback that will be invoked when the form is pressed
  final VoidCallback? onPressed;

  @override
  State<AppDecimalFormField> createState() => _AppDecimalFormFieldState();
}

class _AppDecimalFormFieldState extends State<AppDecimalFormField> {
  late final AppDecimalController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? AppDecimalController(initialValue: Decimal.zero);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppFormField(
      isRequired: widget.isRequired,
      readOnly: widget.readOnly,
      icon: widget.icon,
      label: widget.label,
      controller: _controller.textEditingController,
      onPressed: widget.onPressed,
    );
  }
}

/// Controller for [AppDateTimeFormField]
final class AppDateTimeController extends ChangeNotifier {
  /// Creates new [AppDateTimeController]
  AppDateTimeController({DateTime? initialValue})
    : _textEditingController = TextEditingController(
        text: initialValue?.dateTimeFormat,
      ),
      _value = initialValue;

  final TextEditingController _textEditingController;

  /// Returns [TextEditingController]
  TextEditingController get textEditingController => _textEditingController;

  DateTime? _value;

  /// Returns current [DateTime] value
  DateTime? get value => _value;

  set value(DateTime? value) {
    _value = value;
    _textEditingController.text = value?.dateTimeFormat ?? '';
    notifyListeners();
  }
}

/// Creates new [TextFormField] for date time input
class AppDateTimeFormField extends StatefulWidget {
  /// Creates new [AppDateTimeFormField]
  const AppDateTimeFormField({
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

  /// [AppDateTimeController] that managing input value
  ///
  /// If null, a new controller will be created with [DateTime.now()]
  final AppDateTimeController? controller;

  /// Callback that will be invoked when the form is pressed
  final VoidCallback? onPressed;

  @override
  State<AppDateTimeFormField> createState() => _AppDateTimeFormFieldState();
}

class _AppDateTimeFormFieldState extends State<AppDateTimeFormField> {
  late final AppDateTimeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? AppDateTimeController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _onPressed() async {
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDate: _controller.value,
    );
    if (!context.mounted) return;
    _controller.value = pickedDate;
  }

  @override
  Widget build(BuildContext context) {
    return AppFormField(
      isRequired: widget.isRequired,
      readOnly: widget.readOnly,
      icon: widget.icon,
      label: widget.label,
      controller: _controller.textEditingController,
      onPressed: () {
        widget.onPressed?.call();
        unawaited(_onPressed());
      },
    );
  }
}
