import 'package:flutter/widgets.dart';
import 'package:journexa_app/ui/shared/theme.dart';

/// Creates new [Column] with [title] on top of [description].
///
/// Uses this to shows errors or exceptions as name suggested.
///
/// [bottom] will be rendered on the bottom of the [Column].
/// Typically used to shows actions or buttons.
class AppExceptionBox extends StatelessWidget {
  /// Creates new [AppExceptionBox]
  const AppExceptionBox({
    this.title,
    this.description,
    this.bottom,
    super.key,
  });

  /// Title that will be showed on top of [description]
  final String? title;

  /// Description that will be showed on top of [bottom]
  final String? description;

  /// Bottom that will be showed on the bottom
  ///
  /// Typically for buttons.
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          spacing: 8,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null)
              Text(
                title!,
                textAlign: TextAlign.center,
                style: context.text.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (description != null)
              Text(
                description!,
                textAlign: TextAlign.center,
                style: context.text.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        ?bottom,
      ],
    );
  }
}
