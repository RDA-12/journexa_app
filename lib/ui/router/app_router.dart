import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:journexa_app/ui/auth/bloc/auth_bloc.dart';
import 'package:journexa_app/ui/auth/login_page.dart';
import 'package:journexa_app/ui/expense_categories/add_expense_category_page.dart';
import 'package:journexa_app/ui/expense_categories/expense_categories_list_page.dart';
import 'package:journexa_app/ui/home/home_page.dart';
import 'package:journexa_app/ui/income_categories/add_income_categories_list_page.dart';
import 'package:journexa_app/ui/income_categories/add_income_category_page.dart';
import 'package:journexa_app/ui/initialize/initialize_page.dart';
import 'package:journexa_app/ui/splash/splash_page.dart';
import 'package:journexa_app/ui/transactions/transactions_list_page.dart';
import 'package:journexa_app/ui/wallets/add_wallet_page.dart';
import 'package:journexa_app/ui/wallets/wallets_list_page.dart';

/// [AppRouter] is holds the [GoRouter] instance.
class AppRouter {
  /// Creates new [AppRouter]
  new({required this.authBloc});

  /// Used to trigger redirect when this bloc state changes
  final AuthBloc authBloc;

  /// Return [GoRouter] instance for the app.
  late final GoRouter config = GoRouter(
    initialLocation: '/',
    refreshListenable: _AuthBlocListenable(authBloc),
    // TODO(RDA-12): test redirection
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;
      return authState.maybeWhen(
        unauthenticated: () => '/login',
        orElse: () => null,
      );
    },
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

class _AuthBlocListenable extends ChangeNotifier {
  new(AuthBloc authBloc) {
    notifyListeners();
    _subscription = authBloc.stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  Future<void> dispose() async {
    await _subscription.cancel();
    super.dispose();
  }
}
