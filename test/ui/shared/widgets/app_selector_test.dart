import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/ui/shared/l10n/app_localizations.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';

import '../../util.dart';

class TestClass {
  const new({required this.id, required this.name});

  final int id;
  final String name;
}

final expectedTranslations = {
  'id': {
    'errorTitle': 'Gagal mendapatkan data',
    'errorDescription': 'Terjadi kesalahan internal',
    'emptyDescription': 'Tidak ada data',
    'loadingSemantics': 'Loading data',
  },
  'en': {
    'errorTitle': 'Failed to get items',
    'errorDescription': 'Internal exception error',
    'emptyDescription': 'No items found',
    'loadingSemantics': 'Loading data',
  },
};

void main() {
  final items = List.generate(5, (idx) => TestClass(id: idx, name: '$idx'));

  Future<void> pumpWidget(
    WidgetTester tester, {
    required AppSelectorController<TestClass> controller,
    Locale locale = const Locale('en'),
    void Function(String?)? onSearch,
    Widget Function(BuildContext, AppException)? exceptionBuilder,
    bool isRequired = false,
    String? label,
    VoidCallback? onPressed,
  }) {
    return pumpForWidgetTest(
      tester,
      locale: locale,
      widget: AppSelector(
        controller: controller,
        isRequired: isRequired,
        label: label,
        onSearch: onSearch,
        exceptionBuilder: exceptionBuilder,
        onPressed: onPressed,
      ),
    );
  }

  Future<void> openItems(
    WidgetTester tester, {
    bool waitUntilSettle = true,
  }) async {
    final finder = find.byType(AppFormField);
    await tester.tap(finder);
    if (waitUntilSettle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }

  group(
    'Render',
    () {
      testWidgets(
        'shows correct AppFormField',
        (tester) async {
          final controller = AppSelectorController<TestClass>(
            displayAsString: (it) => it.name,
          );
          await pumpWidget(
            tester,
            controller: controller,
            isRequired: true,
            label: 'test',
          );

          final finder = find.byType(AppFormField);
          expect(finder, findsOneWidget);
          final widget = tester.widget<AppFormField>(finder);
          expect(widget.readOnly, true);
          expect(widget.isRequired, true);
          expect(widget.label, 'test');
        },
      );

      testWidgets('shows selected value in form field', (tester) async {
        final controller = AppSelectorController<TestClass>(
          displayAsString: (it) => it.name,
          initialValue: items.first,
        );
        await pumpWidget(
          tester,
          controller: controller,
        );

        expect(find.text(items.first.name), findsOneWidget);
      });

      testWidgets('shows loading when loading on show items', (tester) async {
        final controller = AppSelectorController<TestClass>(
          displayAsString: (it) => it.name,
        )..isLoading = true;
        await pumpWidget(
          tester,
          controller: controller,
        );
        await openItems(tester, waitUntilSettle: false);

        expect(find.byType(LoadingIndicator), findsOneWidget);
      });

      testWidgets('shows empty when no items on show items', (tester) async {
        final controller = AppSelectorController<TestClass>(
          displayAsString: (it) => it.name,
        );
        await pumpWidget(
          tester,
          controller: controller,
        );
        await openItems(tester);

        expect(find.byType(AppEmptyBox), findsOneWidget);
      });

      testWidgets(
        'shows items when items are present on show items',
        (tester) async {
          final controller = AppSelectorController<TestClass>(
            displayAsString: (it) => it.name,
            initialItems: items,
          );
          await pumpWidget(
            tester,
            controller: controller,
          );
          await openItems(tester);

          expect(find.byType(CheckboxListTile), findsNWidgets(items.length));
          for (final item in items) {
            expect(find.text(item.name), findsOneWidget);
          }
        },
      );

      testWidgets('shows selected item when value is set on show items', (
        tester,
      ) async {
        final controller = AppSelectorController<TestClass>(
          displayAsString: (it) => it.name,
          initialItems: items,
          initialValue: items.first,
        );
        await pumpWidget(
          tester,
          controller: controller,
        );
        expect(find.text(items.first.name), findsOneWidget);

        await openItems(tester);
        final finder = find.byWidgetPredicate(
          (it) => it is CheckboxListTile && it.value == true,
        );
        expect(finder, findsOneWidget);
      });

      for (final locale in AppLocalizations.supportedLocales) {
        final translations = expectedTranslations[locale.languageCode]!;

        final errorTitle = translations['errorTitle']!;
        testWidgets(
          'shows correct error title for ${locale.languageCode} '
          'when exceptionBuilder not provided',
          (tester) async {
            final controller = AppSelectorController<TestClass>(
              displayAsString: (it) => it.name,
              initialItems: [],
            )..lastError = AppException.test();
            await pumpWidget(tester, controller: controller, locale: locale);

            await openItems(tester);
            expect(find.text(errorTitle), findsOneWidget);
          },
        );

        final errorDescription = translations['errorDescription']!;
        testWidgets(
          'shows correct error description for ${locale.languageCode} '
          'when exceptionBuilder not provided',
          (tester) async {
            final controller = AppSelectorController<TestClass>(
              displayAsString: (it) => it.name,
              initialItems: [],
            )..lastError = AppException.test();
            await pumpWidget(tester, controller: controller, locale: locale);

            await openItems(tester);
            expect(find.text(errorDescription), findsOneWidget);
          },
        );

        final emptyDescription = translations['emptyDescription']!;
        testWidgets(
          'shows correct empty description for ${locale.languageCode}',
          (tester) async {
            final controller = AppSelectorController<TestClass>(
              displayAsString: (it) => it.name,
              initialItems: [],
            );
            await pumpWidget(tester, controller: controller, locale: locale);

            await openItems(tester);
            expect(find.text(emptyDescription), findsOneWidget);
          },
        );
      }

      testWidgets(
        'shows correct Widget when exceptionBuilder provided ',
        (tester) async {
          final controller = AppSelectorController<TestClass>(
            displayAsString: (it) => it.name,
            initialItems: [],
          )..lastError = AppException.test();
          await pumpWidget(
            tester,
            controller: controller,
            exceptionBuilder: (context, error) => const Text('Custom Error'),
          );

          await openItems(tester);
          expect(find.text('Custom Error'), findsOneWidget);
        },
      );
    },
  );

  group('Interactions', () {
    testWidgets(
      'set correct value when selected',
      (tester) async {
        final controller = AppSelectorController<TestClass>(
          displayAsString: (it) => it.name,
          initialItems: items,
        );
        await pumpWidget(
          tester,
          controller: controller,
        );
        await openItems(tester);

        final tileFinder = find.ancestor(
          of: find.text(items.first.name),
          matching: find.byType(CheckboxListTile),
        );
        expect(tileFinder, findsOneWidget);

        await tester.tap(tileFinder);
        await tester.pumpAndSettle();

        expect(controller.value, items.first);
        expect(find.text(items.first.name), findsOneWidget);
      },
    );

    testWidgets(
      'calls search when search button is pressed',
      (tester) async {
        final controller = AppSelectorController<TestClass>(
          displayAsString: (it) => it.name,
        );
        var pressed = false;
        await pumpWidget(
          tester,
          controller: controller,
          onPressed: () {
            pressed = true;
          },
        );
        await openItems(tester);

        expect(pressed, isTrue);
      },
    );
  });

  group('a11y', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final translations = expectedTranslations[locale.languageCode]!;

      final loadingSemantics = translations['loadingSemantics']!;
      testWidgets(
        'shows correct loading semantics for ${locale.languageCode}',
        (tester) async {
          final controller = AppSelectorController<TestClass>(
            displayAsString: (it) => it.name,
          )..isLoading = true;
          await pumpWidget(
            tester,
            controller: controller,
            locale: locale,
          );

          await openItems(tester, waitUntilSettle: false);
          expect(find.bySemanticsLabel(loadingSemantics), findsOneWidget);
        },
      );
    }
  });

  group('AppSelectorController', () {
    test('set status to loading when isLoading is set to true', () {
      final controller = AppSelectorController<TestClass>(
        displayAsString: (it) => it.name,
      )..isLoading = true;

      expect(controller.status, SelectorStatus.loading);
    });

    test('set status to error when lastError is set', () {
      final controller = AppSelectorController<TestClass>(
        displayAsString: (it) => it.name,
      )..lastError = AppException.test();

      expect(controller.lastError, AppException.test());
      expect(controller.status, SelectorStatus.error);
    });

    test('set status to idle when set new items', () {
      final controller = AppSelectorController<TestClass>(
        displayAsString: (it) => it.name,
      )..items = items;

      expect(controller.items, items);
      expect(controller.status, SelectorStatus.idle);
    });
  });
}
