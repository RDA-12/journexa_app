import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/ui/shared/widgets/app_button.dart';

void main() {
  Future<void> pumpWidget({
    required WidgetTester tester,
    required String label,
    Widget? icon,
    VoidCallback? onPressed,
    ButtonSize size = ButtonSize.small,
    ButtonType type = ButtonType.outlined,
    ButtonColorType color = ButtonColorType.normal,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton(
            label: label,
            icon: icon,
            onPressed: onPressed,
            size: size,
            type: type,
            color: color,
          ),
        ),
      ),
    );
  }

  group('Render', () {
    for (final color in ButtonColorType.values) {
      for (final type in ButtonType.values) {
        for (final size in ButtonSize.values) {
          testWidgets(
            'shows label for type: $type, '
            'size: $size, color: $color',
            (tester) async {
              await pumpWidget(
                tester: tester,
                label: 'Hello',
                size: size,
                type: type,
                color: color,
              );

              expect(find.text('Hello'), findsOneWidget);
            },
          );

          testWidgets(
            'shows icon when provided for type: $type, '
            'size: $size, color: $color',
            (tester) async {
              await pumpWidget(
                tester: tester,
                label: 'Hello',
                icon: const Icon(Icons.add),
                type: type,
                size: size,
                color: color,
              );

              expect(find.byIcon(Icons.add), findsOneWidget);
            },
          );

          testWidgets(
            'disabled when onPressed is null for type: $type, '
            'size: $size, color: $color',
            (tester) async {
              await pumpWidget(
                tester: tester,
                label: 'Hello',
                type: type,
                size: size,
                color: color,
              );

              late final ButtonStyleButton button;
              switch (type) {
                case ButtonType.outlined:
                  button = tester.widget<OutlinedButton>(
                    find.byType(OutlinedButton),
                  );
                case ButtonType.filled:
                  button = tester.widget<FilledButton>(
                    find.byType(FilledButton),
                  );
              }
              expect(button.onPressed, null);
            },
          );
        }
      }
    }
  });

  group('Interaction', () {
    for (final color in ButtonColorType.values) {
      for (final type in ButtonType.values) {
        for (final size in ButtonSize.values) {
          testWidgets(
            'calls onPressed when pressed for type: $type, '
            'size: $size, color: $color',
            (tester) async {
              var isPressed = false;
              await pumpWidget(
                tester: tester,
                label: 'Hello',
                onPressed: () => isPressed = true,
                type: type,
                size: size,
              );

              await tester.tap(find.byType(AppButton));

              expect(isPressed, true);
            },
          );
        }
      }
    }
  });

  group('a11y', () {
    for (final color in ButtonColorType.values) {
      for (final type in ButtonType.values) {
        for (final size in ButtonSize.values) {
          testWidgets(
            'follows a11y guidelines when label only '
            'for type: $type, size: $size, color: $color',
            (tester) async {
              final handle = tester.ensureSemantics();
              await pumpWidget(
                tester: tester,
                label: 'Hello',
                type: type,
                size: size,
              );

              await expectLater(
                tester,
                meetsGuideline(androidTapTargetGuideline),
              );
              await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
              await expectLater(
                tester,
                meetsGuideline(labeledTapTargetGuideline),
              );
              await expectLater(tester, meetsGuideline(textContrastGuideline));

              handle.dispose();
            },
          );

          testWidgets(
            'follows a11y guidelines when icon is provided '
            'for type: $type, size: $size, color: $color',
            (tester) async {
              final handle = tester.ensureSemantics();
              await pumpWidget(
                tester: tester,
                label: 'Hello',
                type: type,
                size: size,
                icon: const Icon(Icons.add),
              );

              await expectLater(
                tester,
                meetsGuideline(androidTapTargetGuideline),
              );
              await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
              await expectLater(
                tester,
                meetsGuideline(labeledTapTargetGuideline),
              );
              await expectLater(tester, meetsGuideline(textContrastGuideline));

              handle.dispose();
            },
          );

          testWidgets(
            'has correct label when semanticsLabel is provided '
            'for type: $type, size: $size, color: $color',
            (tester) async {
              final handle = tester.ensureSemantics();
              await pumpWidget(
                tester: tester,
                label: 'Hello',
                type: type,
                size: size,
              );

              expect(find.bySemanticsLabel('Hello'), findsOneWidget);

              handle.dispose();
            },
          );

          testWidgets(
            'has correct label when icon is provided '
            'for type: $type, size: $size, color: $color',
            (tester) async {
              final handle = tester.ensureSemantics();
              await pumpWidget(
                tester: tester,
                label: 'Hello',
                type: type,
                size: size,
                icon: const Icon(Icons.add),
              );

              expect(find.bySemanticsLabel('Hello'), findsOneWidget);

              handle.dispose();
            },
          );
        }
      }
    }
  });
}
