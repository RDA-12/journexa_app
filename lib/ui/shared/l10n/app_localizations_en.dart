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

  @override
  String errorAccountAlreadyExists(String name) {
    return '$name with provided name already exists';
  }

  @override
  String get formErrorRequired => 'Required';

  @override
  String get addCashAccountNameLabel => 'Name';

  @override
  String get addCashAccountButtonLabel => 'Add Cash';

  @override
  String get commonCash => 'Cash';

  @override
  String get addCashAccountSuccessMessage => 'Cash successfully added';

  @override
  String get addCashAccountSuccessTitle => 'Cash added';

  @override
  String get addCashAccountFailureTitle => 'Failed to add cash';

  @override
  String get commonRequired => 'Required';

  @override
  String get addCashAccountTitle => 'Add New Cash';

  @override
  String errorAccountNotFound(String code) {
    return 'Account with code $code not found';
  }

  @override
  String get cashAccountsListFailureTitle => 'Failed to get cash data';

  @override
  String get cashAccountsListLoadingSemantics => 'Loading cash data';

  @override
  String get cashAccountsListTitle => 'Cash List';

  @override
  String get cashAccountsListSearchLabel => 'Search Cash';

  @override
  String get commonEmptyTitle => 'Data Not Found';

  @override
  String get cashAccountsListEmptyDescription => 'No cash data was found';

  @override
  String get cashAccountsListAddButtonSemantics => 'Add New Cash';

  @override
  String get commonConfirmLabel => 'OK';

  @override
  String get commonCancelLabel => 'Cancel';

  @override
  String deleteCashAccountDialogTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String deleteCashAccountDialogContent(String name) {
    return 'Data that related to $name will still exist. But, $name will no longer be able to be used for future transactions';
  }

  @override
  String get deleteCashAccountDialogConfirmLabel => 'Delete';

  @override
  String get commonDelete => 'Delete';

  @override
  String deleteCashAccountSemantics(String name) {
    return 'Delete $name';
  }

  @override
  String get commonDeletingLabel => 'Deleting';

  @override
  String deleteCashAccountDeletingSemanticsLabel(String name) {
    return 'Deleting $name';
  }

  @override
  String cashAccountCardSemantics(String name, String balance) {
    return '$name, Balance $balance';
  }

  @override
  String deleteAccountToastMessage(String name) {
    return '$name has been deleted';
  }
}
