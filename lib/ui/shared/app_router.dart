import 'package:go_router/go_router.dart';
import 'package:journexa_app/ui/expense_categories/add_expense_category_page.dart';
import 'package:journexa_app/ui/expense_categories/expense_categories_list_page.dart';
import 'package:journexa_app/ui/home/home_page.dart';
import 'package:journexa_app/ui/income_categories/add_income_categories_list_page.dart';
import 'package:journexa_app/ui/income_categories/add_income_category_page.dart';
import 'package:journexa_app/ui/initialize/initialize_page.dart';
import 'package:journexa_app/ui/login/login_page.dart';
import 'package:journexa_app/ui/splash/splash_page.dart';
import 'package:journexa_app/ui/transactions/transactions_list_page.dart';
import 'package:journexa_app/ui/wallets/add_wallet_page.dart';
import 'package:journexa_app/ui/wallets/wallets_list_page.dart';

/// [AppRouter] is a static class that holds the [GoRouter] instance.
abstract class AppRouter {
  /// Return [GoRouter] instance for the app.
  static GoRouter router = GoRouter(
    initialLocation: '/',
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/initialize',
        builder: (context, state) => const InitializePage(),
      ),
      GoRoute(
        path: '/add-wallet-account',
        builder: (context, state) => const AddWalletPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/wallet-accounts',
        builder: (context, state) => const WalletsListPage(),
      ),
      GoRoute(
        path: '/add-income-category',
        builder: (context, state) => const AddIncomeCategoryPage(),
      ),
      GoRoute(
        path: '/income-categories',
        builder: (context, state) => const IncomeCategoriesListPage(),
      ),
      GoRoute(
        path: '/add-expense-category',
        builder: (context, state) => const AddExpenseCategoryPage(),
      ),
      GoRoute(
        path: '/expense-categories',
        builder: (context, state) => const ExpenseCategoriesListPage(),
      ),
      GoRoute(
        path: '/transactions',
        builder: (context, state) => const TransactionsListPage(),
      ),
    ],
  );
}
