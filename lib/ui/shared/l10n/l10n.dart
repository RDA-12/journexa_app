import 'package:flutter/widgets.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/ui/shared/l10n/app_localizations.dart';
export 'app_localizations.dart';

/// Extension to access AppLocalizations
extension L10nX on BuildContext {
  /// Return [AppLocalizations] instance from the widget tree
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  /// Return language code from [Localizations]
  String get languageCode => Localizations.localeOf(this).languageCode;
}

/// Extension to converts [AppExceptionCode] to localized [String]
extension AppExceptionCodeX on AppExceptionCode {
  /// Return localized [String] of this [AppExceptionCode]
  ///
  /// [data] will be used to format the localized string
  /// Example:
  /// ```dart
  /// const data = {'name': 'Test'};
  /// AppExceptionCode.accountAlreadyExists.toLocalizedString(context, data);
  /// ```
  String toLocalizedString(
    BuildContext context, {
    Map<String, dynamic> data = const {},
  }) => switch (this) {
    AppExceptionCode.internalException => context.l10n.errorInternalException,
    AppExceptionCode.loginCanceled => context.l10n.errorLoginCanceled,
    AppExceptionCode.serverException => context.l10n.errorServerException,
    AppExceptionCode.unauthenticated => context.l10n.errorUnauthenticated,
    AppExceptionCode.accountAlreadyExists =>
      context.l10n.errorAccountAlreadyExists(data['name'] as String),
    AppExceptionCode.accountNotFound => context.l10n.errorAccountNotFound(
      data['code'] as String,
    ),
  };
}
