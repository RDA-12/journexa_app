import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/ui/shared/widgets/app_outlined_button.dart';

void main() {
  Future<void> pumpWidget({
    required WidgetTester tester,
    required String label,
    Widget? icon,
    VoidCallback? onPressed,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppOutlinedButton(
            label: label,
            icon: icon,
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }

  group('Render', () {
    testWidgets('shows label', (tester) async {
      await pumpWidget(tester: tester, label: 'Hello');

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets(
      'shows icon when provided',
      (tester) async {
        await pumpWidget(
          tester: tester,
          label: 'Hello',
          icon: const Icon(Icons.add),
        );

        expect(find.byIcon(Icons.add), findsOneWidget);
      },
    );

    testWidgets('disabled when onPressed is null', (tester) async {
      await pumpWidget(tester: tester, label: 'Hello');

      final button = tester.widget<OutlinedButton>(
        find.byType(OutlinedButton),
      );

      expect(button.onPressed, null);
    });
  });

  group('Interaction', () {
    testWidgets('Calls onPressed when pressed', (tester) async {
      var isPressed = false;
      await pumpWidget(
        tester: tester,
        label: 'Hello',
        onPressed: () => isPressed = true,
      );

      await tester.tap(find.byType(AppOutlinedButton));

      expect(isPressed, true);
    });
  });

  group('a11y', () {
    testWidgets(
      'follows a11y guidelines when label only',
      (tester) async {
        final handle = tester.ensureSemantics();
        await pumpWidget(tester: tester, label: 'Hello');

        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));

        handle.dispose();
      },
    );

    testWidgets(
      'follows a11y guidelines when icon is provided',
      (tester) async {
        final handle = tester.ensureSemantics();
        await pumpWidget(
          tester: tester,
          label: 'Hello',
          icon: const Icon(Icons.add),
        );

        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));

        handle.dispose();
      },
    );

    testWidgets(
      'has correct label when semanticsLabel is provided',
      (tester) async {
        final handle = tester.ensureSemantics();
        await pumpWidget(tester: tester, label: 'Hello');

        expect(find.bySemanticsLabel('Hello'), findsOneWidget);

        handle.dispose();
      },
    );

    testWidgets(
      'has correct label when icon is provided',
      (tester) async {
        final handle = tester.ensureSemantics();
        await pumpWidget(
          tester: tester,
          label: 'Hello',
          icon: const Icon(Icons.add),
        );

        expect(find.bySemanticsLabel('Hello'), findsOneWidget);

        handle.dispose();
      },
    );
  });
}
