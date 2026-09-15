import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/shared/formatter/formatter.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/app_form_field.dart';

import '../../util.dart';

final expectedTranslations = {
  'id': {
    'required': 'Harus diisi',
  },
  'en': {
    'required': 'Required',
  },
};

void main() {
  Future<void> pumpWidget(
    WidgetTester tester, {
    Locale? locale,
    TextEditingController? controller,
    Widget? icon,
    String? label,
    bool? isRequired,
    bool? readOnly,
    VoidCallback? onPressed,
  }) async {
    final formKey = GlobalKey<FormState>();

    return await pumpForWidgetTest(
      tester,
      locale: locale ?? const Locale('en'),
      widget: Form(
        key: formKey,
        child: Column(
          children: [
            AppFormField(
              controller: controller,
              isRequired: isRequired ?? false,
              label: label,
              icon: icon,
              readOnly: readOnly ?? false,
              onPressed: onPressed,
            ),
            FilledButton(
              key: const ValueKey('validator-button'),
              onPressed: () {
                formKey.currentState!.validate();
              },
              child: const Text('Validate'),
            ),
          ],
        ),
      ),
    );
  }

  group('Render', () {
    testWidgets(
      'shows label when provided',
      (tester) async {
        const expectedLabel = 'Test';

        await pumpWidget(
          tester,
          label: expectedLabel,
        );

        expect(find.text(expectedLabel), findsOneWidget);
      },
    );

    testWidgets(
      'shows required (*) when field is required',
      (tester) async {
        const expectedLabel = 'Label';

        await pumpWidget(tester, isRequired: true, label: expectedLabel);

        expect(find.text('$expectedLabel *'), findsOneWidget);
      },
    );

    testWidgets(
      'shows icon when provided',
      (tester) async {
        const expectedIcon = Icon(Icons.abc);

        await pumpWidget(
          tester,
          icon: expectedIcon,
        );

        final iconTypeFinder = find.byType(Icon);
        expect(iconTypeFinder, findsOneWidget);
        final iconWidget = tester.widget<Icon>(iconTypeFinder);
        expect(iconWidget.icon, expectedIcon.icon);
      },
    );

    for (final locale in AppLocalizations.supportedLocales) {
      final expectedRequiredText =
          expectedTranslations[locale.languageCode]!['required']!;

      testWidgets(
        'shows $expectedRequiredText error '
        'when isRequired true but value is empty when submitted',
        (tester) async {
          await pumpWidget(tester, locale: locale, isRequired: true);

          final buttonFinder = find.byKey(const ValueKey('validator-button'));
          await tester.tap(buttonFinder);
          await tester.pump();

          expect(find.text(expectedRequiredText), findsOneWidget);
        },
      );
    }
  });

  group('Interaction', () {
    testWidgets(
      'allows input text',
      (tester) async {
        const expectedText = 'Test';

        await pumpWidget(tester);

        final formFieldFinder = find.byType(TextFormField);
        await tester.enterText(formFieldFinder, expectedText);

        expect(find.text(expectedText), findsOneWidget);
      },
    );

    testWidgets('not allows input text when readOnly true', (tester) async {
      await pumpWidget(tester, readOnly: true);

      final formFieldFinder = find.byType(TextFormField);
      await tester.enterText(formFieldFinder, 'Test');

      expect(find.text('Test'), findsNothing);
    });

    testWidgets('calls onPressed when clicked', (tester) async {
      var isPressed = false;
      await pumpWidget(
        tester,
        onPressed: () {
          isPressed = true;
        },
      );

      final formFieldFinder = find.byType(TextFormField);
      await tester.tap(formFieldFinder);
      await tester.pumpAndSettle();

      expect(isPressed, isTrue);
    });

    testWidgets(
      'uses controller when provided',
      (tester) async {
        const expectedText = 'Test';
        final controller = TextEditingController();
        addTearDown(controller.dispose);

        await pumpWidget(tester, controller: controller);

        final formFieldFinder = find.byType(TextFormField);
        await tester.enterText(formFieldFinder, expectedText);

        expect(controller.text, expectedText);
      },
    );
  });

  group('a11y', () {
    testWidgets(
      'has correct label semantically when isRequired true',
      (tester) async {
        const expectedLabel = 'Test';

        await pumpWidget(tester, label: expectedLabel, isRequired: true);

        expect(
          find.bySemanticsLabel('$expectedLabel, Required'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'has correct label semantically when isRequired false',
      (tester) async {
        const expectedLabel = 'Test';

        await pumpWidget(tester, label: expectedLabel, isRequired: false);

        expect(
          find.bySemanticsLabel(expectedLabel),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'has isTextField flag true',
      (tester) async {
        await pumpWidget(tester);

        final finder = find.byType(AppFormField);
        expect(
          tester.getSemantics(finder),
          isSemantics(isTextField: true, isReadOnly: false),
        );
      },
    );

    testWidgets('has isReadOnly flag when readOnly true', (tester) async {
      await pumpWidget(tester, readOnly: true);

      final finder = find.byType(AppFormField);
      expect(
        tester.getSemantics(finder),
        isSemantics(isTextField: true, isReadOnly: true),
      );
    });
  });

  group('AppDecimalFormField', () {
    Future<void> pumpDecimalFormField(
      WidgetTester tester, {
      Locale? locale,
      AppDecimalController? controller,
      Widget? icon,
      String? label,
      bool? isRequired,
      bool? readOnly,
      VoidCallback? onPressed,
    }) async {
      final formKey = GlobalKey<FormState>();

      return await pumpForWidgetTest(
        tester,
        locale: locale ?? const Locale('en'),
        widget: Form(
          key: formKey,
          child: Column(
            children: [
              AppDecimalFormField(
                controller: controller,
                isRequired: isRequired ?? false,
                label: label,
                icon: icon,
                readOnly: readOnly ?? false,
                onPressed: onPressed,
              ),
              FilledButton(
                key: const ValueKey('validator-button'),
                onPressed: () {
                  formKey.currentState!.validate();
                },
                child: const Text('Validate'),
              ),
            ],
          ),
        ),
      );
    }

    group('Render', () {
      testWidgets('shows correct AppFormField', (tester) async {
        final controller = AppDecimalController();
        const icon = Icon(Icons.search);
        const label = 'label';

        await pumpDecimalFormField(
          tester,
          controller: controller,
          isRequired: false,
          icon: icon,
          label: label,
          readOnly: false,
        );

        final finder = find.byType(AppFormField);
        expect(finder, findsOneWidget);

        final widget = tester.widget<AppFormField>(finder);
        expect(widget.controller, controller.textEditingController);
        expect(widget.isRequired, false);
        expect(widget.icon, icon);
        expect(widget.label, label);
        expect(widget.readOnly, false);
        expect(widget.onPressed, null);
      });

      for (final locale in AppLocalizations.supportedLocales) {
        testWidgets(
          'shows correct formatted decimal for ${locale.languageCode}',
          (tester) async {
            final decimal = Decimal.parse('1234.56');
            final controller = AppDecimalController(initialValue: decimal)
              ..languageCode = locale.languageCode;

            await pumpDecimalFormField(
              tester,
              locale: locale,
              controller: controller,
            );

            expect(
              find.text(decimal.toLocalizedString(locale.languageCode)),
              findsOneWidget,
            );
          },
        );
      }

      testWidgets('uses provided controller', (tester) async {
        final controller = AppDecimalController(
          initialValue: Decimal.zero,
        );
        const input = '1000000';
        final expected = Decimal.parse(input);

        await pumpDecimalFormField(tester, controller: controller);
        await tester.enterText(find.byType(TextFormField), input);
        await tester.pumpAndSettle();

        expect(controller.value, expected);
      });

      testWidgets('shows correct initial value', (tester) async {
        final value = Decimal.parse('1000000');
        final controller = AppDecimalController(
          initialValue: value,
        );

        await pumpDecimalFormField(tester, controller: controller);

        expect(find.text(value.toLocalizedString('en')), findsOneWidget);
      });
    });

    group('Interactions', () {
      testWidgets('allows inputting decimal value', (tester) async {
        final controller = AppDecimalController();
        const input = '1000000';
        final expected = Decimal.parse(input);

        await pumpDecimalFormField(tester, controller: controller);
        await tester.enterText(find.byType(TextFormField), input);
        await tester.pumpAndSettle();

        expect(controller.value, expected);
      });

      testWidgets('does not allow non-decimal input', (tester) async {
        final controller = AppDecimalController();
        const input = 'abc';
        final expected = Decimal.zero;

        await pumpDecimalFormField(tester, controller: controller);
        await tester.enterText(find.byType(TextFormField), input);
        await tester.pumpAndSettle();

        expect(controller.value, expected);
      });
    });

    group('AppDecimalController', () {
      testWidgets('reset value when languageCode changed', (tester) async {
        const expectedInitial = '1,000,000.95';
        const expectedLater = '1.000.000,95';
        final controller = AppDecimalController(
          initialValue: Decimal.parse('1000000.95'),
        );

        expect(
          controller.textEditingController.text,
          expectedInitial,
        );

        controller.languageCode = 'id';
        expect(
          controller.textEditingController.text,
          expectedLater,
        );
      });
    });
  });

  group('AppDateTimeFormField', () {
    Future<void> pumpDateTimeFormField(
      WidgetTester tester, {
      Locale? locale,
      AppDateTimeController? controller,
      Widget? icon,
      String? label,
      bool? isRequired,
      bool? readOnly,
      VoidCallback? onPressed,
    }) async {
      final formKey = GlobalKey<FormState>();

      return await pumpForWidgetTest(
        tester,
        locale: locale ?? const Locale('en'),
        widget: Form(
          key: formKey,
          child: Column(
            children: [
              AppDateTimeFormField(
                controller: controller,
                isRequired: isRequired ?? false,
                label: label,
                icon: icon,
                readOnly: readOnly ?? false,
                onPressed: onPressed,
              ),
              FilledButton(
                key: const ValueKey('validator-button'),
                onPressed: () {
                  formKey.currentState!.validate();
                },
                child: const Text('Validate'),
              ),
            ],
          ),
        ),
      );
    }

    group('Render', () {
      testWidgets(
        'shows correct AppFormField',
        (tester) async {
          final controller = AppDateTimeController();
          const icon = Icon(Icons.search);
          const label = 'label';

          await pumpDateTimeFormField(
            tester,
            controller: controller,
            isRequired: false,
            icon: icon,
            label: label,
            readOnly: false,
          );

          final finder = find.byType(AppFormField);
          expect(finder, findsOneWidget);

          final widget = tester.widget<AppFormField>(finder);
          expect(widget.controller, controller.textEditingController);
          expect(widget.isRequired, false);
          expect(widget.icon, icon);
          expect(widget.label, label);
          expect(widget.readOnly, false);
        },
      );

      testWidgets('shows correct initial value', (tester) async {
        final value = DateTime.now();
        final controller = AppDateTimeController(initialValue: value);

        await pumpDateTimeFormField(tester, controller: controller);

        expect(find.text(value.dateTimeFormat), findsOneWidget);
      });
    });

    group('Interactions', () {
      testWidgets('allows to select date and time', (tester) async {
        final controller = AppDateTimeController();
        final now = DateTime.now();
        final value = DateTime(now.year, now.month, now.day);

        await pumpDateTimeFormField(tester, controller: controller);

        await tester.tap(find.byType(TextFormField));
        await tester.pumpAndSettle();

        await tester.tap(find.text(value.day.toString()));
        await tester.pump();

        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        expect(controller.value, value);
      });
    });
  });
}
