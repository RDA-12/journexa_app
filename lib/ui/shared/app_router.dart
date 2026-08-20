import 'package:go_router/go_router.dart';
import 'package:journexa_app/ui/accounts/add_cash_account_page.dart';
import 'package:journexa_app/ui/accounts/cash_accounts_list_page.dart';
import 'package:journexa_app/ui/home/home_page.dart';
import 'package:journexa_app/ui/initialize/initialize_page.dart';
import 'package:journexa_app/ui/login/login_page.dart';
import 'package:journexa_app/ui/splash/splash_page.dart';

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
        path: '/add-cash-account',
        builder: (context, state) => const AddCashAccountPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/cash-accounts',
        builder: (context, state) => const CashAccountsListPage(),
      ),
    ],
  );
}
