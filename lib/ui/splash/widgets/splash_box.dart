import 'package:flutter/widgets.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/app_logo.dart';

/// Creates an [AppLogo] to be shown in splash page.
///
/// It will set semantics label on the AppLogo
class SplashBox extends StatelessWidget {
  /// Creates new [SplashBox]
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLogo(
      semanticsLabel: context.l10n.splashBoxLabel,
      addSemanticsLabel: true,
    );
  }
}
