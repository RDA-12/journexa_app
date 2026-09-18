import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:journexa_app/ui/auth/login_page.dart';
import 'package:journexa_app/ui/expense_categories/add_expense_category_page.dart';
import 'package:journexa_app/ui/expense_categories/expense_categories_list_page.dart';
import 'package:journexa_app/ui/home/home_page.dart';
import 'package:journexa_app/ui/income_categories/add_income_categories_list_page.dart';
import 'package:journexa_app/ui/income_categories/add_income_category_page.dart';
import 'package:journexa_app/ui/initialize/initialize_page.dart';
import 'package:journexa_app/ui/router/app_route_notifier.dart';
import 'package:journexa_app/ui/router/app_route_redirector.dart';
import 'package:journexa_app/ui/settings/settings_page.dart';
import 'package:journexa_app/ui/splash/splash_page.dart';
import 'package:journexa_app/ui/transactions/add_transaction_page.dart';
import 'package:journexa_app/ui/transactions/transactions_list_page.dart';
import 'package:journexa_app/ui/wallets/add_wallet_page.dart';
import 'package:journexa_app/ui/wallets/wallets_list_page.dart';

part 'app_routes.dart';
part 'app_router.g.dart';

/// [AppRouter] is holds the [GoRouter] instance.
class AppRouter {
  /// Creates new [AppRouter]
  new({required this._routeNotifier, required this._redirectors});

  /// Used to trigger redirect when this notifier emits new value
  final AppRouteNotifier _routeNotifier;

  /// List of redirectors that will be checked in redirect
  final List<AppRouteRedirector> _redirectors;

  /// Return [GoRouter] instance for the app.
  late final GoRouter config = GoRouter(
    initialLocation: '/',
    refreshListenable: _routeNotifier,
    redirect: (context, state) {
      for (final redirector in _redirectors) {
        final nextLocation = redirector.maybeRedirect(context, state);
        if (nextLocation != null) {
          return nextLocation;
        }
      }
      return null;
    },
    routes: $appRoutes,
  );
}
