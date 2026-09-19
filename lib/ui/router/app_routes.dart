part of 'app_router.dart';

/// Root navigator key
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Navigator key for wallets shell within main shell
final walletsShellNavigatorKey = GlobalKey<NavigatorState>();

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

/// Shell for transactions routes
class HomeShell extends StatefulShellBranchData {
  /// Creates new [HomeShell]
  const new();
}

/// Route for home page
class HomeRoute extends GoRouteData with $HomeRoute {
  /// Creates new [HomeRoute]
  const new();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomePage();
}

/// Shell for wallets routes
class WalletsShell extends StatefulShellBranchData {
  /// Creates new [WalletsShell]
  const new();

  /// Nav key for this shell
  static final GlobalKey<NavigatorState> $navigatorKey =
      walletsShellNavigatorKey;
}

/// Route for wallets list page
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

  /// parent nav key of this route
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

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

/// Shell for transactions routes
class TransactionsShell extends StatefulShellBranchData {
  /// Creates new [TransactionsShell]
  const new();
}

/// Route for transactions list page
class TransactionsListRoute extends GoRouteData with $TransactionsListRoute {
  /// Creates new [TransactionsListRoute]
  const new();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const TransactionsListPage();
}

/// Relative route for adding new transaction page
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

/// Shell for transactions routes
class SettingsShell extends StatefulShellBranchData {
  /// Creates new [SettingsShell]
  const new();
}

/// Route for settings page
class SettingsRoute extends GoRouteData with $SettingsRoute {
  /// Creates new [SettingsRoute]
  const new();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SettingsPage();
}

/// Shell route for main page
@TypedStatefulShellRoute<MainShellRoute>(
  branches: [
    TypedStatefulShellBranch<HomeShell>(
      routes: [
        TypedGoRoute<HomeRoute>(path: '/home'),
      ],
    ),
    TypedStatefulShellBranch<TransactionsShell>(
      routes: [
        TypedGoRoute<TransactionsListRoute>(
          path: '/transactions',
          routes: [
            TypedRelativeGoRoute<AddTransactionRoute>(
              path: 'add/:type',
            ),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<WalletsShell>(
      routes: [
        TypedGoRoute<WalletsListRoute>(
          path: '/wallets',
          routes: [
            TypedGoRoute<AddWalletRoute>(path: 'add'),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<SettingsShell>(
      routes: [
        TypedGoRoute<SettingsRoute>(path: '/settings'),
      ],
    ),
  ],
)
class MainShellRoute extends StatefulShellRouteData {
  /// Creates new [MainShellRoute]
  const new();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return MainShellPage(
      currentIndex: navigationShell.currentIndex,
      onDestinationChanged: (index) => navigationShell.goBranch(
        index,
        initialLocation: navigationShell.currentIndex == index,
      ),
      child: navigationShell,
    );
  }
}
