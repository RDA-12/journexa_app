// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get loginButtonGoogleLabel => 'Login with Google';

  @override
  String get commonAppName => 'Journexa';

  @override
  String get commonAppTagline => 'Your personal financial partner';

  @override
  String get loginSuccessTitle => 'Login successful';

  @override
  String get loginSuccessMessage => 'Redirecting to initialization process...';

  @override
  String get loginFailedTitle => 'Login failed';

  @override
  String get errorInternalException => 'Internal exception error';

  @override
  String get errorLoginCanceled => 'Login process was canceled';

  @override
  String get errorServerException => 'Server exception error';

  @override
  String get errorUnauthenticated =>
      'You are not logged in. Please login to continue.';

  @override
  String get initializeLoadingText => 'Initializing...';

  @override
  String get initializeErrorTitle => 'Initialization failed';

  @override
  String get appLogoLabel => 'Journexa logo';

  @override
  String get splashBoxLabel => 'Opening Journexa app';
}
