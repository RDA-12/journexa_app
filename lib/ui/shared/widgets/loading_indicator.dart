import 'package:flutter/material.dart';

/// Creates new [CircularProgressIndicator] widget
///
/// It uses [SizedBox] to ensure the [CircularProgressIndicator] has the
/// correct size.
class LoadingIndicator extends StatelessWidget {
  /// Creates new [LoadingIndicator]
  ///
  /// [semanticsLabel] is advised to be provided when the [LoadingIndicator]
  /// is stand alone (not wrapped in a widget that provides [semanticsLabel]).
  const new({
    this.size = 24,
    this.semanticsLabel,
    super.key,
  });

  /// Label for accessibility
  final String? semanticsLabel;

  /// Size of the [LoadingIndicator].
  ///
  /// Defaults to 24
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: CircularProgressIndicator(
        semanticsLabel: semanticsLabel,
      ),
    );
  }
}
