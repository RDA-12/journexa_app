import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';

/// Creates new [SvgPicture] to shows app logo.
class AppLogo extends StatelessWidget {
  /// Creates new [AppLogo]
  const AppLogo({
    this.size,
    this.addSemanticsLabel = false,
    this.semanticsLabel,
    super.key,
  });

  /// Size of the logo
  ///
  /// Default to 24
  final double? size;

  /// Whether to add semantics label or not.
  /// Useful when the logo is not main content of the widget.
  /// So, the semantics label not collides with main widget.
  ///
  /// Default to false
  final bool addSemanticsLabel;

  /// Semantics label that will be set
  ///
  /// If [addSemanticsLabel] is true and [semanticsLabel] not provided,
  /// it will use default semantics label.
  ///
  /// It will be ignored when [addSemanticsLabel] is false.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final effectiveSize = size ?? 24;

    return SvgPicture.asset(
      'assets/logo/logo.svg',
      semanticsLabel: addSemanticsLabel
          ? semanticsLabel ?? context.l10n.appLogoLabel
          : null,
      width: effectiveSize,
      height: effectiveSize,
    );
  }
}
