import 'package:flutter/widgets.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/theme.dart';

/// Creates [Column] contains app name on top of app tagline
class LoginHeader extends StatelessWidget {
  /// Creates new [LoginHeader]
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      children: [
        Text(
          context.l10n.commonAppName,
          style: context.text.displayLarge,
        ),
        Text(
          context.l10n.commonAppTagline,
          style: context.text.bodyMedium,
        ),
      ],
    );
  }
}
