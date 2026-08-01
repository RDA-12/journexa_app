import 'package:go_router/go_router.dart';
import 'package:journexa_app/ui/login/login_page.dart';

/// [AppRouter] is a static class that holds the [GoRouter] instance.
abstract class AppRouter {
  /// Return [GoRouter] instance for the app.
  static GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: <GoRoute>[
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
    ],
  );
}
