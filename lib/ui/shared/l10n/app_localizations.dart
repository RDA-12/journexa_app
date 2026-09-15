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
  String get addWalletNameLabel;

  /// Default label for save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSaveLabel;

  /// Wallet label
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get commonWallet;

  /// Message to be showed when wallet added successfully
  ///
  /// In en, this message translates to:
  /// **'Wallet successfully added'**
  String get addWalletSuccessMessage;

  /// Title for success state in add wallet page
  ///
  /// In en, this message translates to:
  /// **'Wallet added'**
  String get addWalletSuccessTitle;

  /// Title for error state in add wallet page
  ///
  /// In en, this message translates to:
  /// **'Failed to add wallet'**
  String get addWalletFailureTitle;

  /// Label for required, usually for semantics
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get commonRequired;

  /// Title for add wallet page
  ///
  /// In en, this message translates to:
  /// **'Add New Wallet'**
  String get addWalletTitle;

  /// Message for when an account is not found
  ///
  /// In en, this message translates to:
  /// **'Account with code {code} not found'**
  String errorAccountNotFound(String code);

  /// Title for error state in wallets list page
  ///
  /// In en, this message translates to:
  /// **'Failed to get wallet data'**
  String get walletsListFailureTitle;

  /// Semantics label for loading state in wallets list page
  ///
  /// In en, this message translates to:
  /// **'Loading wallet data'**
  String get walletsListLoadingSemantics;

  /// Title for wallets list page
  ///
  /// In en, this message translates to:
  /// **'Wallet List'**
  String get walletsListTitle;

  /// Label for search input on wallets list
  ///
  /// In en, this message translates to:
  /// **'Search Wallet'**
  String get walletsListSearchLabel;

  /// Default title to shows data not found
  ///
  /// In en, this message translates to:
  /// **'Data Not Found'**
  String get commonEmptyTitle;

  /// Description to be showed when wallet data is empty
  ///
  /// In en, this message translates to:
  /// **'No wallet data was found'**
  String get walletsListEmptyDescription;

  /// Semantics label for add button on wallets list
  ///
  /// In en, this message translates to:
  /// **'Add New Wallet'**
  String get walletsListAddButtonSemantics;

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

  /// Title for delete wallet dialog
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deleteWalletDialogTitle(String name);

  /// Content for delete wallet dialog
  ///
  /// In en, this message translates to:
  /// **'Data that related to {name} will still exist. But, {name} will no longer be able to be used for future transactions'**
  String deleteWalletDialogContent(String name);

  /// Confirm label for delete wallet dialog
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteWalletDialogConfirmLabel;

  /// Default label for delete
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// Semantics label for delete wallet button
  ///
  /// In en, this message translates to:
  /// **'Delete {name}'**
  String deleteWalletSemantics(String name);

  /// Default label when deleting entity is in progress
  ///
  /// In en, this message translates to:
  /// **'Deleting'**
  String get commonDeletingLabel;

  /// Semantics label for button when wallet deletion is in progress
  ///
  /// In en, this message translates to:
  /// **'Deleting {name}'**
  String deleteWalletDeletingSemanticsLabel(String name);

  /// Semantics label for WalletCard widget
  ///
  /// In en, this message translates to:
  /// **'{name}, Balance {balance}'**
  String walletAccountCardSemantics(String name, String balance);

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

  /// Semantics label for update wallet button
  ///
  /// In en, this message translates to:
  /// **'Update {name}'**
  String updateWalletSemantics(String name);

  /// Default label when updating entity is in progress
  ///
  /// In en, this message translates to:
  /// **'Updating'**
  String get commonUpdatingLabel;

  /// Semantics label for button when wallet update is in progress
  ///
  /// In en, this message translates to:
  /// **'Updating {name}'**
  String updateWalletUpdatingSemanticsLabel(String name);

  /// Message to be showed on toast when Account has been updated
  ///
  /// In en, this message translates to:
  /// **'{name} has been updated'**
  String updateAccountToastMessage(String name);

  /// Title for error state in delete wallet toast
  ///
  /// In en, this message translates to:
  /// **'Failed to delete wallet data'**
  String get deleteWalletToastFailureTitle;

  /// Title for error state in update wallet toast
  ///
  /// In en, this message translates to:
  /// **'Failed to update wallet data'**
  String get updateWalletToastFailureTitle;

  /// Label for name field on add income category
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get addIncomeCategoryNameLabel;

  /// Message to be showed when income category added successfully
  ///
  /// In en, this message translates to:
  /// **'Income category successfully added'**
  String get addIncomeCategorySuccessMessage;

  /// Title for success state in add income category page
  ///
  /// In en, this message translates to:
  /// **'Income category added'**
  String get addIncomeCategorySuccessTitle;

  /// Title for error state in add income category page
  ///
  /// In en, this message translates to:
  /// **'Failed to add income category'**
  String get addIncomeCategoryFailureTitle;

  /// Title for add income category page
  ///
  /// In en, this message translates to:
  /// **'Add Income Category'**
  String get addIncomeCategoryTitle;

  /// Message to be showed when users trying to creates wallet with same name
  ///
  /// In en, this message translates to:
  /// **'Wallet with name {name} already exists'**
  String errorWalletNameAlreadyExists(String name);

  /// Message to be showed when users trying to creates income category with same name
  ///
  /// In en, this message translates to:
  /// **'Category with name {name} already exists'**
  String errorCategoryAlreadyExists(String name);

  /// Title for error state in income categories list page
  ///
  /// In en, this message translates to:
  /// **'Failed to get income categories data'**
  String get incomeCategoriesListFailureTitle;

  /// Semantics label for loading state in income categories list page
  ///
  /// In en, this message translates to:
  /// **'Loading income categories data'**
  String get incomeCategoriesListLoadingSemantics;

  /// Title for income categories list page
  ///
  /// In en, this message translates to:
  /// **'Income Categories List'**
  String get incomeCategoriesListTitle;

  /// Label for search input on income categories list
  ///
  /// In en, this message translates to:
  /// **'Search Income Category'**
  String get incomeCategoriesListSearchLabel;

  /// Description to be showed when income categories data is empty
  ///
  /// In en, this message translates to:
  /// **'No income categories data was found'**
  String get incomeCategoriesListEmptyDescription;

  /// Semantics label for add button on income categories list
  ///
  /// In en, this message translates to:
  /// **'Add Income Category'**
  String get incomeCategoriesListAddButtonSemantics;

  /// Title for delete income category dialog
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deleteIncomeCategoryDialogTitle(String name);

  /// Content for delete income category dialog
  ///
  /// In en, this message translates to:
  /// **'Data related to {name} income category will still exist. But, {name} income category will no longer be able to be used for future income data'**
  String deleteIncomeCategoryDialogContent(String name);

  /// Confirm label for delete income category dialog
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteIncomeCategoryDialogConfirmLabel;

  /// Semantics label for delete income category button
  ///
  /// In en, this message translates to:
  /// **'Delete {name}'**
  String deleteIncomeCategorySemantics(String name);

  /// Semantics label for button when income category deletion is in progress
  ///
  /// In en, this message translates to:
  /// **'Deleting {name}'**
  String deleteIncomeCategoryDeletingSemanticsLabel(String name);

  /// Message to be showed on toast when income category has been deleted
  ///
  /// In en, this message translates to:
  /// **'{name} has been deleted'**
  String deleteIncomeCategoryToastMessage(String name);

  /// Semantics label for update income category button
  ///
  /// In en, this message translates to:
  /// **'Update {name}'**
  String updateIncomeCategorySemantics(String name);

  /// Semantics label for button when income category update is in progress
  ///
  /// In en, this message translates to:
  /// **'Updating {name}'**
  String updateIncomeCategoryUpdatingSemanticsLabel(String name);

  /// Message to be showed on toast when income category has been updated
  ///
  /// In en, this message translates to:
  /// **'{name} has been updated'**
  String updateIncomeCategoryToastMessage(String name);

  /// Title for error state in delete income category toast
  ///
  /// In en, this message translates to:
  /// **'Failed to delete income category'**
  String get deleteIncomeCategoryToastFailureTitle;

  /// Title for error state in update income category toast
  ///
  /// In en, this message translates to:
  /// **'Failed to update income category'**
  String get updateIncomeCategoryToastFailureTitle;

  /// Label for name field on add expense category
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get addExpenseCategoryNameLabel;

  /// Title to be showed when expense category added successfully
  ///
  /// In en, this message translates to:
  /// **'Expense category added'**
  String get addExpenseCategorySuccessTitle;

  /// Message to be showed when expense category added successfully
  ///
  /// In en, this message translates to:
  /// **'Expense category successfully added'**
  String get addExpenseCategorySuccessMessage;

  /// Title for error state in add expense category page
  ///
  /// In en, this message translates to:
  /// **'Failed to add expense category'**
  String get addExpenseCategoryFailureTitle;

  /// Title for add expense category page
  ///
  /// In en, this message translates to:
  /// **'Add Expense Category'**
  String get addExpenseCategoryTitle;

  /// Title for error state in expense categories list page
  ///
  /// In en, this message translates to:
  /// **'Failed to get expense categories data'**
  String get expenseCategoriesListFailureTitle;

  /// Semantics label for loading state in expense categories list page
  ///
  /// In en, this message translates to:
  /// **'Loading expense categories data'**
  String get expenseCategoriesListLoadingSemantics;

  /// Title for expense categories list page
  ///
  /// In en, this message translates to:
  /// **'Expense Categories List'**
  String get expenseCategoriesListTitle;

  /// Label for search input on expense categories list
  ///
  /// In en, this message translates to:
  /// **'Search Expense Category'**
  String get expenseCategoriesListSearchLabel;

  /// Description to be showed when expense categories data is empty
  ///
  /// In en, this message translates to:
  /// **'No expense categories data was found'**
  String get expenseCategoriesListEmptyDescription;

  /// Semantics label for add button on expense categories list
  ///
  /// In en, this message translates to:
  /// **'Add Expense Category'**
  String get expenseCategoriesListAddButtonSemantics;

  /// Title for delete expense category dialog
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deleteExpenseCategoryDialogTitle(String name);

  /// Content for delete expense category dialog
  ///
  /// In en, this message translates to:
  /// **'Data related to {name} expense category will still exist. But, {name} expense category will no longer be able to be used for future expense data'**
  String deleteExpenseCategoryDialogContent(String name);

  /// Confirm label for delete expense category dialog
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteExpenseCategoryDialogConfirmLabel;

  /// Semantics label for delete expense category button
  ///
  /// In en, this message translates to:
  /// **'Delete {name}'**
  String deleteExpenseCategorySemantics(String name);

  /// Semantics label for button when expense category deletion is in progress
  ///
  /// In en, this message translates to:
  /// **'Deleting {name}'**
  String deleteExpenseCategoryDeletingSemanticsLabel(String name);

  /// Message to be showed on toast when expense category has been deleted
  ///
  /// In en, this message translates to:
  /// **'{name} has been deleted'**
  String deleteExpenseCategoryToastMessage(String name);

  /// Semantics label for update expense category button
  ///
  /// In en, this message translates to:
  /// **'Update {name}'**
  String updateExpenseCategorySemantics(String name);

  /// Semantics label for button when expense category update is in progress
  ///
  /// In en, this message translates to:
  /// **'Updating {name}'**
  String updateExpenseCategoryUpdatingSemanticsLabel(String name);

  /// Message to be showed on toast when expense category has been updated
  ///
  /// In en, this message translates to:
  /// **'{name} has been updated'**
  String updateExpenseCategoryToastMessage(String name);

  /// Title for error state in delete expense category toast
  ///
  /// In en, this message translates to:
  /// **'Failed to delete expense category'**
  String get deleteExpenseCategoryToastFailureTitle;

  /// Title for error state in update expense category toast
  ///
  /// In en, this message translates to:
  /// **'Failed to update expense category'**
  String get updateExpenseCategoryToastFailureTitle;

  /// Error message when wallet doesn't have enough balance
  ///
  /// In en, this message translates to:
  /// **'Wallet {name} doesn\'t have enough balance'**
  String errorInsufficientWalletBalance(String name);

  /// Title when AppSelector have error status
  ///
  /// In en, this message translates to:
  /// **'Failed to get items'**
  String get appSelectorErrorTitle;

  /// Description when AppSelector have empty status
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get appSelectorEmptyItemsDescription;

  /// Default semantics label for standalone LoadingIndicator
  ///
  /// In en, this message translates to:
  /// **'Loading data'**
  String get commonLoadingSemanticsLabel;

  /// Label for date field in transfer money form
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get transferMoneyDateLabel;

  /// Label for source wallet selector in transfer money form
  ///
  /// In en, this message translates to:
  /// **'Source Wallet'**
  String get transferMoneySourceLabel;

  /// Label for destination wallet selector in transfer money form
  ///
  /// In en, this message translates to:
  /// **'Destination Wallet'**
  String get transferMoneyDestinationLabel;

  /// Label for amount field in transfer money form
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get transferMoneyAmountLabel;

  /// Label for fee field in transfer money form
  ///
  /// In en, this message translates to:
  /// **'Transfer Fee'**
  String get transferMoneyFeeLabel;

  /// Label for notes field in transfer money form
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get transferMoneyNotesLabel;

  /// Submit button in transfer money form
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transferMoneySubmitButton;

  /// Title for toast success state in transfer money page
  ///
  /// In en, this message translates to:
  /// **'Transfer recorded'**
  String get transferMoneySuccessTitle;

  /// Message for toast success state in transfer money page
  ///
  /// In en, this message translates to:
  /// **'{amount} transfer from {sourceName} to {destName} have been recorded'**
  String transferMoneySuccessMessage(
    String sourceName,
    String destName,
    String amount,
  );

  /// Title for toast failure state in transfer money page
  ///
  /// In en, this message translates to:
  /// **'Failed to record transfer'**
  String get transferMoneyFailureTitle;

  /// Title for Add transaction page
  ///
  /// In en, this message translates to:
  /// **'Record new transaction'**
  String get addTransactionTitle;

  /// Label for date field in income form
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get incomeDateLabel;

  /// Label for wallet selector in income form
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get incomeWalletLabel;

  /// Label for category selector in income form
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get incomeCategoryLabel;

  /// Label for amount field in income form
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get incomeAmountLabel;

  /// Label for notes field in income form
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get incomeNotesLabel;

  /// Submit button in income form
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get incomeSubmitButton;

  /// Title for toast success state in income page
  ///
  /// In en, this message translates to:
  /// **'Income recorded'**
  String get incomeSuccessTitle;

  /// Message for toast success state in income page
  ///
  /// In en, this message translates to:
  /// **'{amount} income to {walletName} for {categoryName} have been recorded'**
  String incomeSuccessMessage(
    String walletName,
    String categoryName,
    String amount,
  );

  /// Title for toast failure state in income page
  ///
  /// In en, this message translates to:
  /// **'Failed to record income'**
  String get incomeFailureTitle;

  /// Label for date field in expense form
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get expenseDateLabel;

  /// Label for wallet selector in expense form
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get expenseWalletLabel;

  /// Label for category selector in expense form
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get expenseCategoryLabel;

  /// Label for amount field in expense form
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get expenseAmountLabel;

  /// Label for notes field in expense form
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get expenseNotesLabel;

  /// Submit button in expense form
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expenseSubmitButton;

  /// Title for toast success state in expense page
  ///
  /// In en, this message translates to:
  /// **'Expense recorded'**
  String get expenseSuccessTitle;

  /// Message for toast success state in expense page
  ///
  /// In en, this message translates to:
  /// **'{amount} expense from {walletName} for {categoryName} have been recorded'**
  String expenseSuccessMessage(
    String walletName,
    String categoryName,
    String amount,
  );

  /// Title for toast failure state in expense page
  ///
  /// In en, this message translates to:
  /// **'Failed to record expense'**
  String get expenseFailureTitle;

  /// Semantics label for transaction card
  ///
  /// In en, this message translates to:
  /// **'Transfer {amount} to {destWallet} from {sourceWallet} at {time}'**
  String transactionCardTransferSemantics(
    String destWallet,
    String sourceWallet,
    String amount,
    String time,
  );

  /// Semantics label for transaction card
  ///
  /// In en, this message translates to:
  /// **'Income {amount} to {walletName} for {categoryName} at {time}'**
  String transactionCardIncomeSemantics(
    String walletName,
    String categoryName,
    String amount,
    String time,
  );

  /// Semantics label for transaction card
  ///
  /// In en, this message translates to:
  /// **'Expense {amount} from {walletName} for {categoryName} at {time}'**
  String transactionCardExpenseSemantics(
    String walletName,
    String categoryName,
    String amount,
    String time,
  );

  /// Subtitle for transaction card
  ///
  /// In en, this message translates to:
  /// **'from {sourceWallet}'**
  String transactionCardTransferSubtitle(String sourceWallet);

  /// Subtitle for transaction card
  ///
  /// In en, this message translates to:
  /// **'from {walletName}'**
  String transactionCardExpenseSubtitle(String walletName);

  /// Subtitle for transaction card
  ///
  /// In en, this message translates to:
  /// **'to {walletName}'**
  String transactionCardIncomeSubtitle(String walletName);

  /// Text shown when failed to get transactions data
  ///
  /// In en, this message translates to:
  /// **'Failed to get transactions data'**
  String get transactionsListFailureTitle;

  /// Accessibility label for loading indicator in transactions list
  ///
  /// In en, this message translates to:
  /// **'Loading transactions data'**
  String get transactionsListLoadingSemantics;

  /// Description for empty transactions list
  ///
  /// In en, this message translates to:
  /// **'No transactions data was found'**
  String get transactionsListEmptyDescription;

  /// Semantics label for loading indicator in wallets carousel
  ///
  /// In en, this message translates to:
  /// **'Loading wallets data'**
  String get homeWalletsLoadingSemantics;

  /// Description for empty wallets carousel
  ///
  /// In en, this message translates to:
  /// **'No wallets data was found'**
  String get homeWalletsEmptyDescription;

  /// Title for toast failure state in home page
  ///
  /// In en, this message translates to:
  /// **'Failed to get wallets data'**
  String get homeWalletsFailureTitle;

  /// Title to be showed in Transactions list page
  ///
  /// In en, this message translates to:
  /// **'Transactions List'**
  String get transactionsListTitle;

  /// Label to shows total wallets balances in home page
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get homeWalletsTotalBalanceLabel;

  /// Label for MTDCard type expense
  ///
  /// In en, this message translates to:
  /// **'Total Expense'**
  String get mtdCardExpenseLabel;

  /// Label for MTDCard type income
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get mtdCardIncomeLabel;

  /// Label for MTDCard type net
  ///
  /// In en, this message translates to:
  /// **'Net Balance'**
  String get mtdCardNetLabel;

  /// Semantics label for loading indicator in mtd section
  ///
  /// In en, this message translates to:
  /// **'Loading net balance this month'**
  String get mtdSectionLoadingSemantics;

  /// Title for MTD data in home page
  ///
  /// In en, this message translates to:
  /// **'This month balance'**
  String get homeMTDTitle;

  /// Title for transactions list section in home page
  ///
  /// In en, this message translates to:
  /// **'Latest transactions this month'**
  String get homeTransactionsListTitle;
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
