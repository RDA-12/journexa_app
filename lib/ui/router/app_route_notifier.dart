import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:journexa_app/ui/auth/bloc/auth_bloc.dart';

/// Notifier for AppRouter to trigger redirect
class AppRouteNotifier extends ChangeNotifier {
  /// Creates new [AppRouteNotifier]
  new({required AuthBloc authBloc}) {
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
