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
  String get addWalletNameLabel => 'Name';

  @override
  String get commonSaveLabel => 'Save';

  @override
  String get commonWallet => 'Wallet';

  @override
  String get addWalletSuccessMessage => 'Wallet successfully added';

  @override
  String get addWalletSuccessTitle => 'Wallet added';

  @override
  String get addWalletFailureTitle => 'Failed to add wallet';

  @override
  String get commonRequired => 'Required';

  @override
  String get addWalletTitle => 'Add New Wallet';

  @override
  String errorAccountNotFound(String code) {
    return 'Account with code $code not found';
  }

  @override
  String get walletsListFailureTitle => 'Failed to get wallet data';

  @override
  String get walletsListLoadingSemantics => 'Loading wallet data';

  @override
  String get walletsListTitle => 'Wallet List';

  @override
  String get walletsListSearchLabel => 'Search Wallet';

  @override
  String get commonEmptyTitle => 'Data Not Found';

  @override
  String get walletsListEmptyDescription => 'No wallet data was found';

  @override
  String get walletsListAddButtonSemantics => 'Add New Wallet';

  @override
  String get commonConfirmLabel => 'OK';

  @override
  String get commonCancelLabel => 'Cancel';

  @override
  String deleteWalletDialogTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String deleteWalletDialogContent(String name) {
    return 'Data that related to $name will still exist. But, $name will no longer be able to be used for future transactions';
  }

  @override
  String get deleteWalletDialogConfirmLabel => 'Delete';

  @override
  String get commonDelete => 'Delete';

  @override
  String deleteWalletSemantics(String name) {
    return 'Delete $name';
  }

  @override
  String get commonDeletingLabel => 'Deleting';

  @override
  String deleteWalletDeletingSemanticsLabel(String name) {
    return 'Deleting $name';
  }

  @override
  String walletAccountCardSemantics(String name, String balance) {
    return '$name, Balance $balance';
  }

  @override
  String deleteAccountToastMessage(String name) {
    return '$name has been deleted';
  }

  @override
  String get commonUpdateLabel => 'Update';

  @override
  String updateWalletSemantics(String name) {
    return 'Update $name';
  }

  @override
  String get commonUpdatingLabel => 'Updating';

  @override
  String updateWalletUpdatingSemanticsLabel(String name) {
    return 'Updating $name';
  }

  @override
  String updateAccountToastMessage(String name) {
    return '$name has been updated';
  }

  @override
  String get deleteWalletToastFailureTitle => 'Failed to delete wallet data';

  @override
  String get updateWalletToastFailureTitle => 'Failed to update wallet data';

  @override
  String get addIncomeCategoryNameLabel => 'Name';

  @override
  String get addIncomeCategorySuccessMessage =>
      'Income category successfully added';

  @override
  String get addIncomeCategorySuccessTitle => 'Income category added';

  @override
  String get addIncomeCategoryFailureTitle => 'Failed to add income category';

  @override
  String get addIncomeCategoryTitle => 'Add Income Category';
}
