import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/ui/shared/widgets/app_outlined_button.dart';

void main() {
  Future<void> pumpWidget({
    required WidgetTester tester,
    required String label,
    Widget? icon,
    VoidCallback? onPressed,
    ButtonSize size = ButtonSize.small,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppOutlinedButton(
            label: label,
            icon: icon,
            onPressed: onPressed,
            size: size,
          ),
        ),
      ),
    );
  }

  group('Render', () {
    for (final size in ButtonSize.values) {
      testWidgets('shows label for size $size', (tester) async {
        await pumpWidget(tester: tester, label: 'Hello', size: size);

        expect(find.text('Hello'), findsOneWidget);
      });

      testWidgets(
        'shows icon when provided for size $size',
        (tester) async {
          await pumpWidget(
            tester: tester,
            label: 'Hello',
            icon: const Icon(Icons.add),
            size: size,
          );

          expect(find.byIcon(Icons.add), findsOneWidget);
        },
      );

      testWidgets(
        'disabled when onPressed is null for size $size',
        (tester) async {
          await pumpWidget(tester: tester, label: 'Hello', size: size);

          final button = tester.widget<OutlinedButton>(
            find.byType(OutlinedButton),
          );

          expect(button.onPressed, null);
        },
      );
    }
  });

  group('Interaction', () {
    for (final size in ButtonSize.values) {
      testWidgets(
        'Calls onPressed when pressed for size $size',
        (tester) async {
          var isPressed = false;
          await pumpWidget(
            tester: tester,
            label: 'Hello',
            onPressed: () => isPressed = true,
          );

          await tester.tap(find.byType(AppOutlinedButton));

          expect(isPressed, true);
        },
      );
    }
  });

  group('a11y', () {
    for (final size in ButtonSize.values) {
      testWidgets(
        'follows a11y guidelines when label only for size $size',
        (tester) async {
          final handle = tester.ensureSemantics();
          await pumpWidget(tester: tester, label: 'Hello', size: size);

          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          await expectLater(tester, meetsGuideline(textContrastGuideline));

          handle.dispose();
        },
      );

      testWidgets(
        'follows a11y guidelines when icon is provided for size $size',
        (tester) async {
          final handle = tester.ensureSemantics();
          await pumpWidget(
            tester: tester,
            label: 'Hello',
            size: size,
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
        'has correct label when semanticsLabel is provided for size $size',
        (tester) async {
          final handle = tester.ensureSemantics();
          await pumpWidget(tester: tester, label: 'Hello', size: size);

          expect(find.bySemanticsLabel('Hello'), findsOneWidget);

          handle.dispose();
        },
      );

      testWidgets(
        'has correct label when icon is provided for size $size',
        (tester) async {
          final handle = tester.ensureSemantics();
          await pumpWidget(
            tester: tester,
            label: 'Hello',
            size: size,
            icon: const Icon(Icons.add),
          );

          expect(find.bySemanticsLabel('Hello'), findsOneWidget);

          handle.dispose();
        },
      );
    }
  });
}
