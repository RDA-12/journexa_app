import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// Label for Login with Google button
  ///
  /// In en, this message translates to:
  /// **'Login with Google'**
  String get loginButtonGoogleLabel;

  /// App name
  ///
  /// In en, this message translates to:
  /// **'Journexa'**
  String get commonAppName;

  /// App tagline
  ///
  /// In en, this message translates to:
  /// **'Your personal financial partner'**
  String get commonAppTagline;

  /// Login successful title
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get loginSuccessTitle;

  /// Login successful message
  ///
  /// In en, this message translates to:
  /// **'Redirecting to initialization process...'**
  String get loginSuccessMessage;

  /// Login failed title
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailedTitle;

  /// Internal exception error message
  ///
  /// In en, this message translates to:
  /// **'Internal exception error'**
  String get errorInternalException;

  /// Login canceled error message
  ///
  /// In en, this message translates to:
  /// **'Login process was canceled'**
  String get errorLoginCanceled;

  /// Server exception error message
  ///
  /// In en, this message translates to:
  /// **'Server exception error'**
  String get errorServerException;

  /// Message when user is not logged in
  ///
  /// In en, this message translates to:
  /// **'You are not logged in. Please login to continue.'**
  String get errorUnauthenticated;

  /// Loading indicator text for initialize page
  ///
  /// In en, this message translates to:
  /// **'Initializing...'**
  String get initializeLoadingText;

  /// Title for error state in initialize page
  ///
  /// In en, this message translates to:
  /// **'Initialization failed'**
  String get initializeErrorTitle;

  /// Semantics label for app logo
  ///
  /// In en, this message translates to:
  /// **'Journexa logo'**
  String get appLogoLabel;

  /// Semantics label for splash box
  ///
  /// In en, this message translates to:
  /// **'Opening Journexa app'**
  String get splashBoxLabel;

  /// Message when created Account already exists
  ///
  /// In en, this message translates to:
  /// **'{name} with provided name already exists'**
  String errorAccountAlreadyExists(String name);

  /// Message showed when a TextField is required but the value is empty
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get formErrorRequired;

  /// Label for name field
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get addCashAccountNameLabel;

  /// Default label for save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSaveLabel;

  /// Cash label
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get commonCash;

  /// Message to be showed when cash account added successfully
  ///
  /// In en, this message translates to:
  /// **'Cash successfully added'**
  String get addCashAccountSuccessMessage;

  /// Title for success state in add cash account page
  ///
  /// In en, this message translates to:
  /// **'Cash added'**
  String get addCashAccountSuccessTitle;

  /// Title for error state in add cash account page
  ///
  /// In en, this message translates to:
  /// **'Failed to add cash'**
  String get addCashAccountFailureTitle;

  /// Label for required, usually for semantics
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get commonRequired;

  /// Title for add cash account page
  ///
  /// In en, this message translates to:
  /// **'Add New Cash'**
  String get addCashAccountTitle;

  /// Message for when an account is not found
  ///
  /// In en, this message translates to:
  /// **'Account with code {code} not found'**
  String errorAccountNotFound(String code);

  /// Title for error state in cash accounts list page
  ///
  /// In en, this message translates to:
  /// **'Failed to get cash data'**
  String get cashAccountsListFailureTitle;

  /// Semantics label for loading state in cash accounts list page
  ///
  /// In en, this message translates to:
  /// **'Loading cash data'**
  String get cashAccountsListLoadingSemantics;

  /// Title for cash accounts list page
  ///
  /// In en, this message translates to:
  /// **'Cash List'**
  String get cashAccountsListTitle;

  /// Label for search input on cash accounts list
  ///
  /// In en, this message translates to:
  /// **'Search Cash'**
  String get cashAccountsListSearchLabel;

  /// Default title to shows data not found
  ///
  /// In en, this message translates to:
  /// **'Data Not Found'**
  String get commonEmptyTitle;

  /// Description to be showed when cash data is empty
  ///
  /// In en, this message translates to:
  /// **'No cash data was found'**
  String get cashAccountsListEmptyDescription;

  /// Semantics label for add button on cash accounts list
  ///
  /// In en, this message translates to:
  /// **'Add New Cash'**
  String get cashAccountsListAddButtonSemantics;

  /// Default label for confirm button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonConfirmLabel;

  /// Default label for cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancelLabel;

  /// Title for delete cash account dialog
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deleteCashAccountDialogTitle(String name);

  /// Content for delete cash account dialog
  ///
  /// In en, this message translates to:
  /// **'Data that related to {name} will still exist. But, {name} will no longer be able to be used for future transactions'**
  String deleteCashAccountDialogContent(String name);

  /// Confirm label for delete cash account dialog
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteCashAccountDialogConfirmLabel;

  /// Default label for delete
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// Semantics label for delete cash account button
  ///
  /// In en, this message translates to:
  /// **'Delete {name}'**
  String deleteCashAccountSemantics(String name);

  /// Default label when deleting entity is in progress
  ///
  /// In en, this message translates to:
  /// **'Deleting'**
  String get commonDeletingLabel;

  /// Semantics label for button when cash account deletion is in progress
  ///
  /// In en, this message translates to:
  /// **'Deleting {name}'**
  String deleteCashAccountDeletingSemanticsLabel(String name);

  /// Semantics label for CashAccountCard widget
  ///
  /// In en, this message translates to:
  /// **'{name}, Balance {balance}'**
  String cashAccountCardSemantics(String name, String balance);

  /// Message to be showed on toast when Account has been deleted
  ///
  /// In en, this message translates to:
  /// **'{name} has been deleted'**
  String deleteAccountToastMessage(String name);

  /// Defauled label for update button
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get commonUpdateLabel;

  /// Semantics label for update cash account button
  ///
  /// In en, this message translates to:
  /// **'Update {name}'**
  String updateCashAccountSemantics(String name);

  /// Default label when updating entity is in progress
  ///
  /// In en, this message translates to:
  /// **'Updating'**
  String get commonUpdatingLabel;

  /// Semantics label for button when cash account update is in progress
  ///
  /// In en, this message translates to:
  /// **'Updating {name}'**
  String updateCashAccountUpdatingSemanticsLabel(String name);

  /// Message to be showed on toast when Account has been updated
  ///
  /// In en, this message translates to:
  /// **'{name} has been updated'**
  String updateAccountToastMessage(String name);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
