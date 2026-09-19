import 'dart:async';

import 'package:flutter/material.dart';
import 'package:journexa_app/ui/router/router.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';

/// Page to shows user' settings
class SettingsPage extends StatelessWidget {
  /// Creates new [SettingsPage]
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settingsTitle),
      ),
      body: Padding(
        padding: context.pagePadding,
        child: Column(
          spacing: 24,
          children: [
            Column(
              spacing: 8,
              children: [
                ListTile(
                  leading: const Icon(Icons.payments_rounded),
                  title: Text(
                    context.l10n.settingsIncomeCategoriesLabel,
                    semanticsLabel:
                        context.l10n.settingsIncomeCategoriesSemantics,
                  ),
                  onTap: () {
                    unawaited(
                      const IncomeCategoriesListRoute().push<void>(context),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.receipt_long_rounded),
                  title: Text(
                    context.l10n.settingsExpenseCategoriesLabel,
                    semanticsLabel:
                        context.l10n.settingsExpenseCategoriesSemantics,
                  ),
                  onTap: () async {
                    unawaited(
                      const ExpenseCategoriesListRoute().push<void>(context),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
