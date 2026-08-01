import 'package:flutter/widgets.dart';
import 'package:journexa_app/ui/shared/l10n/app_localizations.dart';
export 'app_localizations.dart';

/// Extension to access AppLocalizations
extension L10nX on BuildContext {
  /// Return [AppLocalizations] instance from the widget tree
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
