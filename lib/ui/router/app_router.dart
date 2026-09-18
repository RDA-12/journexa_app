import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:journexa_app/ui/auth/bloc/auth_bloc.dart';
import 'package:journexa_app/ui/auth/login_page.dart';
import 'package:journexa_app/ui/expense_categories/add_expense_category_page.dart';
import 'package:journexa_app/ui/expense_categories/expense_categories_list_page.dart';
import 'package:journexa_app/ui/home/home_page.dart';
import 'package:journexa_app/ui/income_categories/add_income_categories_list_page.dart';
import 'package:journexa_app/ui/income_categories/add_income_category_page.dart';
import 'package:journexa_app/ui/initialize/initialize_page.dart';
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
    routes: $appRoutes,
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
