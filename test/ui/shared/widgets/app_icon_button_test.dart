import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/ui/shared/widgets/app_icon_button.dart';

void main() {
  Future<void> pumpWidget(
    WidgetTester tester, {
    Widget icon = const Icon(Icons.add_rounded),
    String semanticsLabel = 'Label',
    VoidCallback? onPressed,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppIconButton(
            icon: icon,
            onPressed: onPressed,
            semanticsLabel: semanticsLabel,
          ),
        ),
      ),
    );
  }

  group('Render', () {
    testWidgets(
      'shows correct icon',
      (tester) async {
        const expectedIcon = Icon(Icons.import_contacts);

        await pumpWidget(tester, icon: expectedIcon);

        expect(find.byWidget(expectedIcon), findsOneWidget);
      },
    );
  });

  group('Interactions', () {
    testWidgets('calls onPressed when pressed', (tester) async {
      var isPressed = false;

      await pumpWidget(tester, onPressed: () => isPressed = true);

      await tester.tap(find.byType(AppIconButton));

      expect(isPressed, true);
    });

    testWidgets(
      'shows correct tooltip when long pressed',
      (tester) async {
        await pumpWidget(tester, semanticsLabel: 'tooltip');

        await tester.longPress(find.byType(AppIconButton));
        await tester.pumpAndSettle();

        expect(find.text('tooltip'), findsOneWidget);
      },
    );
  });

  group('a11y', () {
    testWidgets(
      'has correct label semantically',
      (tester) async {
        await pumpWidget(tester, semanticsLabel: 'semantics');

        expect(find.byTooltip('semantics'), findsOneWidget);
      },
    );

    testWidgets(
      'follows a11y guidelines',
      (tester) async {
        final handle = tester.ensureSemantics();
        await pumpWidget(tester);

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
  });
}
