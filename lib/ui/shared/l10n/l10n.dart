import 'package:flutter/widgets.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/ui/shared/l10n/app_localizations.dart';
export 'app_localizations.dart';

/// Extension to access AppLocalizations
extension L10nX on BuildContext {
  /// Return [AppLocalizations] instance from the widget tree
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

/// Extension to converts [AppExceptionCode] to localized [String]
extension AppExceptionCodeX on AppExceptionCode {
  /// Return localized [String] of this [AppExceptionCode]
  String toLocalizedString(BuildContext context) => switch (this) {
    AppExceptionCode.internalException => context.l10n.errorInternalException,
    AppExceptionCode.loginCanceled => context.l10n.errorLoginCanceled,
    AppExceptionCode.serverException => context.l10n.errorServerException,
  };
}
