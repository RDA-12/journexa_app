part of 'app_router.dart';

/// Route for splash page
@TypedGoRoute<SplashRoute>(path: '/')
class SplashRoute extends GoRouteData with $SplashRoute {
  /// Creates new [SplashRoute]
  const new();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SplashPage();
}

/// Route for login page
@TypedGoRoute<LoginRoute>(path: '/login')
class LoginRoute extends GoRouteData with $LoginRoute {
  /// Creates new [LoginRoute]
  const new();

  @override
  Widget build(BuildContext context, GoRouterState state) => const LoginPage();
}

/// Route for initialize page
@TypedGoRoute<InitializeRoute>(path: '/initialize')
class InitializeRoute extends GoRouteData with $InitializeRoute {
  /// Creates new [InitializeRoute]
  const new();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const InitializePage();
}

/// Route for home page
@TypedGoRoute<HomeRoute>(path: '/home')
class HomeRoute extends GoRouteData with $HomeRoute {
  /// Creates new [HomeRoute]
  const new();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomePage();
}

/// Route for wallets list page
@TypedGoRoute<WalletsListRoute>(
  path: '/wallets',
  routes: [
    TypedGoRoute<AddWalletRoute>(path: 'add'),
  ],
)
class WalletsListRoute extends GoRouteData with $WalletsListRoute {
  /// Creates new [WalletsListRoute]
  const new();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const WalletsListPage();
}

/// Route for wallets list page
class AddWalletRoute extends GoRouteData with $AddWalletRoute {
  /// Creates new [AddWalletRoute]
  const new();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const AddWalletPage();
}

/// Route for income categories list page
@TypedGoRoute<IncomeCategoriesListRoute>(
  path: '/income-categories',
  routes: [TypedGoRoute<AddIncomeCategoryRoute>(path: 'add')],
)
class IncomeCategoriesListRoute extends GoRouteData
    with $IncomeCategoriesListRoute {
  /// Creates new [IncomeCategoriesListRoute]
  const new();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const IncomeCategoriesListPage();
}

/// Route for adding new income category page
class AddIncomeCategoryRoute extends GoRouteData with $AddIncomeCategoryRoute {
  /// Creates new [AddIncomeCategoryRoute]
  const new();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const AddIncomeCategoryPage();
}

/// Route for expense categories list page
@TypedGoRoute<ExpenseCategoriesListRoute>(
  path: '/expense-categories',
  routes: [TypedGoRoute<AddExpenseCategoryRoute>(path: 'add')],
)
class ExpenseCategoriesListRoute extends GoRouteData
    with $ExpenseCategoriesListRoute {
  /// Creates new [ExpenseCategoriesListRoute]
  const new();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ExpenseCategoriesListPage();
}

/// Route for adding new expense category page
class AddExpenseCategoryRoute extends GoRouteData
    with $AddExpenseCategoryRoute {
  /// Creates new [AddExpenseCategoryRoute]
  const new();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const AddExpenseCategoryPage();
}

/// Route for transactions list page
@TypedGoRoute<TransactionsListRoute>(
  path: '/transactions',
  routes: [
    TypedRelativeGoRoute<AddTransactionRoute>(path: 'add/:type'),
  ],
)
class TransactionsListRoute extends GoRouteData with $TransactionsListRoute {
  /// Creates new [TransactionsListRoute]
  const new();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const TransactionsListPage();
}

/// Relative route for adding new transaction page
@TypedRelativeGoRoute<AddTransactionRoute>(path: 'add/:type')
class AddTransactionRoute extends RelativeGoRouteData
    with $AddTransactionRoute {
  /// Creates new [AddTransactionRoute]
  const new(this.type);

  /// type of transactions that will be added
  final TransactionType type;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      AddTransactionPage(type: type);
}

/// Route for settings page
@TypedGoRoute<SettingsRoute>(path: '/settings')
class SettingsRoute extends GoRouteData with $SettingsRoute {
  /// Creates new [SettingsRoute]
  const new();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SettingsPage();
}
