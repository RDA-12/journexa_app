import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:toastification/toastification.dart';

/// Pump widget with [Scaffold].
///
/// uses [pumpForPageTest] to let [widget] wrap with [Scaffold]
/// by itself.
///
/// This is useful to test basic widget that not includes
/// [Scaffold]
Future<void> pumpForWidgetTest(
  WidgetTester tester, {
  required Widget widget,
  required Locale locale,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: Scaffold(
        body: widget,
      ),
    ),
  );
}

/// Pump widget without [Scaffold] and includes [GoRouter].
///
/// This is useful to test page widget that includes
/// [GoRouter]'s navigation.
///
/// [routes] is a map of routes that will be added to the router.
/// The key is the path of the route and
/// the value is the widget to be placed in the route.
/// Useful to test navigation between pages.
Future<void> pumpForPageTest(
  WidgetTester tester, {
  required Map<String, Widget> routes,
  required Locale locale,
  String initialLocation = '/',
}) async {
  await tester.pumpWidget(
    ToastificationWrapper(
      config: const ToastificationConfig(
        alignment: Alignment.bottomCenter,
        maxDescriptionLines: 2,
        maxTitleLines: 1,
        maxToastLimit: 5,
      ),
      child: MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        routerConfig: GoRouter(
          initialLocation: initialLocation,
          routes: [
            ...routes.entries.map(
              (e) => GoRoute(
                path: e.key,
                builder: (context, state) => e.value,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Pump widget with 2x textScaler
Future<void> pumpForLargeFontTest(
  WidgetTester tester, {
  required Widget widget,
  required Locale locale,
}) async {
  await tester.pumpWidget(
    ToastificationWrapper(
      config: const ToastificationConfig(
        alignment: Alignment.bottomCenter,
        maxDescriptionLines: 2,
        maxTitleLines: 1,
        maxToastLimit: 5,
      ),
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        home: Builder(
          builder: (context) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(2),
              ),
              child: Scaffold(
                body: widget,
              ),
            );
          },
        ),
      ),
    ),
  );
}
