import 'package:flutter/material.dart';
import 'package:journexa_app/ui/shared/theme.dart';

/// Creates new [Column] with [title] on top of [description]
class AppEmptyBox extends StatelessWidget {
  /// Creates new [AppEmptyBox]
  const new({
    this.title,
    this.description,
    super.key,
  });

  /// Title to be showed
  final String? title;

  /// Description to be showed under [title]
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: Column(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Semantics(
              header: true,
              child: Text(
                title!,
                textAlign: TextAlign.center,
                style: context.text.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (description != null)
            Text(
              description!,
              textAlign: TextAlign.center,
              style: context.text.bodyMedium,
            ),
        ],
      ),
    );
  }
}
