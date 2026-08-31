import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

    return pumpForWidgetTest(
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
}
