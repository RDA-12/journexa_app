import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';

/// Page that show when user is logged in
class HomePage extends StatelessWidget {
  /// Creates new [HomePage]
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppButton(
            onPressed: () {
              unawaited(context.push('/cash-accounts'));
            },
            label: 'Add Cash Account',
          ),
        ],
      ),
    );
  }
}
