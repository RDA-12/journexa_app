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

  @override
  String errorWalletNameAlreadyExists(String name) {
    return 'Wallet with name $name already exists';
  }

  @override
  String errorCategoryAlreadyExists(String name) {
    return 'Category with name $name already exists';
  }

  @override
  String get incomeCategoriesListFailureTitle =>
      'Failed to get income categories data';

  @override
  String get incomeCategoriesListLoadingSemantics =>
      'Loading income categories data';

  @override
  String get incomeCategoriesListTitle => 'Income Categories List';

  @override
  String get incomeCategoriesListSearchLabel => 'Search Income Category';

  @override
  String get incomeCategoriesListEmptyDescription =>
      'No income categories data was found';

  @override
  String get incomeCategoriesListAddButtonSemantics => 'Add Income Category';

  @override
  String deleteIncomeCategoryDialogTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String deleteIncomeCategoryDialogContent(String name) {
    return 'Data related to $name income category will still exist. But, $name income category will no longer be able to be used for future income data';
  }

  @override
  String get deleteIncomeCategoryDialogConfirmLabel => 'Delete';

  @override
  String deleteIncomeCategorySemantics(String name) {
    return 'Delete $name';
  }

  @override
  String deleteIncomeCategoryDeletingSemanticsLabel(String name) {
    return 'Deleting $name';
  }

  @override
  String deleteIncomeCategoryToastMessage(String name) {
    return '$name has been deleted';
  }

  @override
  String updateIncomeCategorySemantics(String name) {
    return 'Update $name';
  }

  @override
  String updateIncomeCategoryUpdatingSemanticsLabel(String name) {
    return 'Updating $name';
  }

  @override
  String updateIncomeCategoryToastMessage(String name) {
    return '$name has been updated';
  }

  @override
  String get deleteIncomeCategoryToastFailureTitle =>
      'Failed to delete income category';

  @override
  String get updateIncomeCategoryToastFailureTitle =>
      'Failed to update income category';

  @override
  String get addExpenseCategoryNameLabel => 'Name';

  @override
  String get addExpenseCategorySuccessTitle => 'Expense category added';

  @override
  String get addExpenseCategorySuccessMessage =>
      'Expense category successfully added';

  @override
  String get addExpenseCategoryFailureTitle => 'Failed to add expense category';

  @override
  String get addExpenseCategoryTitle => 'Add Expense Category';

  @override
  String get expenseCategoriesListFailureTitle =>
      'Failed to get expense categories data';

  @override
  String get expenseCategoriesListLoadingSemantics =>
      'Loading expense categories data';

  @override
  String get expenseCategoriesListTitle => 'Expense Categories List';

  @override
  String get expenseCategoriesListSearchLabel => 'Search Expense Category';

  @override
  String get expenseCategoriesListEmptyDescription =>
      'No expense categories data was found';

  @override
  String get expenseCategoriesListAddButtonSemantics => 'Add Expense Category';

  @override
  String deleteExpenseCategoryDialogTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String deleteExpenseCategoryDialogContent(String name) {
    return 'Data related to $name expense category will still exist. But, $name expense category will no longer be able to be used for future expense data';
  }

  @override
  String get deleteExpenseCategoryDialogConfirmLabel => 'Delete';

  @override
  String deleteExpenseCategorySemantics(String name) {
    return 'Delete $name';
  }

  @override
  String deleteExpenseCategoryDeletingSemanticsLabel(String name) {
    return 'Deleting $name';
  }

  @override
  String deleteExpenseCategoryToastMessage(String name) {
    return '$name has been deleted';
  }

  @override
  String updateExpenseCategorySemantics(String name) {
    return 'Update $name';
  }

  @override
  String updateExpenseCategoryUpdatingSemanticsLabel(String name) {
    return 'Updating $name';
  }

  @override
  String updateExpenseCategoryToastMessage(String name) {
    return '$name has been updated';
  }

  @override
  String get deleteExpenseCategoryToastFailureTitle =>
      'Failed to delete expense category';

  @override
  String get updateExpenseCategoryToastFailureTitle =>
      'Failed to update expense category';

  @override
  String errorInsufficientWalletBalance(String name) {
    return 'Wallet $name doesn\'t have enough balance';
  }

  @override
  String get appSelectorErrorTitle => 'Failed to get items';

  @override
  String get appSelectorEmptyItemsDescription => 'No items found';

  @override
  String get commonLoadingSemanticsLabel => 'Loading data';

  @override
  String get transferMoneyDateLabel => 'Date';

  @override
  String get transferMoneySourceLabel => 'Source Wallet';

  @override
  String get transferMoneyDestinationLabel => 'Destination Wallet';

  @override
  String get transferMoneyAmountLabel => 'Amount';

  @override
  String get transferMoneyFeeLabel => 'Transfer Fee';

  @override
  String get transferMoneyNotesLabel => 'Notes';

  @override
  String get transferMoneySubmitButton => 'Transfer';

  @override
  String get transferMoneySuccessTitle => 'Transfer recorded';

  @override
  String transferMoneySuccessMessage(
    String sourceName,
    String destName,
    String amount,
  ) {
    return '$amount transfer from $sourceName to $destName have been recorded';
  }

  @override
  String get transferMoneyFailureTitle => 'Failed to record transfer';

  @override
  String get addTransactionTitle => 'Record new transaction';

  @override
  String get incomeDateLabel => 'Date';

  @override
  String get incomeWalletLabel => 'Wallet';

  @override
  String get incomeCategoryLabel => 'Category';

  @override
  String get incomeAmountLabel => 'Amount';

  @override
  String get incomeNotesLabel => 'Notes';

  @override
  String get incomeSubmitButton => 'Income';

  @override
  String get incomeSuccessTitle => 'Income recorded';

  @override
  String incomeSuccessMessage(
    String walletName,
    String categoryName,
    String amount,
  ) {
    return '$amount income to $walletName for $categoryName have been recorded';
  }

  @override
  String get incomeFailureTitle => 'Failed to record income';

  @override
  String get expenseDateLabel => 'Date';

  @override
  String get expenseWalletLabel => 'Wallet';

  @override
  String get expenseCategoryLabel => 'Category';

  @override
  String get expenseAmountLabel => 'Amount';

  @override
  String get expenseNotesLabel => 'Notes';

  @override
  String get expenseSubmitButton => 'Expense';

  @override
  String get expenseSuccessTitle => 'Expense recorded';

  @override
  String expenseSuccessMessage(
    String walletName,
    String categoryName,
    String amount,
  ) {
    return '$amount expense from $walletName for $categoryName have been recorded';
  }

  @override
  String get expenseFailureTitle => 'Failed to record expense';

  @override
  String transactionCardTransferSemantics(
    String destWallet,
    String sourceWallet,
    String amount,
    String time,
  ) {
    return 'Transfer $amount to $destWallet from $sourceWallet at $time';
  }

  @override
  String transactionCardIncomeSemantics(
    String walletName,
    String categoryName,
    String amount,
    String time,
  ) {
    return 'Income $amount to $walletName for $categoryName at $time';
  }

  @override
  String transactionCardExpenseSemantics(
    String walletName,
    String categoryName,
    String amount,
    String time,
  ) {
    return 'Expense $amount from $walletName for $categoryName at $time';
  }

  @override
  String transactionCardTransferSubtitle(String sourceWallet) {
    return 'from $sourceWallet';
  }

  @override
  String transactionCardExpenseSubtitle(String walletName) {
    return 'from $walletName';
  }

  @override
  String transactionCardIncomeSubtitle(String walletName) {
    return 'to $walletName';
  }

  @override
  String get transactionsListFailureTitle => 'Failed to get transactions data';

  @override
  String get transactionsListLoadingSemantics => 'Loading transactions data';

  @override
  String get transactionsListEmptyDescription =>
      'No transactions data was found';

  @override
  String get homeWalletsLoadingSemantics => 'Loading wallets data';

  @override
  String get homeWalletsEmptyDescription => 'No wallets data was found';

  @override
  String get homeWalletsFailureTitle => 'Failed to get wallets data';

  @override
  String get transactionsListTitle => 'Transactions List';
}
