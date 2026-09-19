import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/ui/shell/widgets/widgets.dart';

import '../../util.dart';

void main() {
  Future<void> pumpWidget(
    WidgetTester tester, {
    VoidCallback? onPressed,
    String? semanticsLabel,
  }) {
    return pumpForWidgetTest(
      tester,
      locale: const Locale('en'),
      widget: AppFabAction(
        label: 'label',
        semanticsLabel: semanticsLabel,
        icon: const Icon(Icons.add_rounded),
        onPressed: onPressed ?? () {},
      ),
    );
  }

  group('Render', () {
    testWidgets('shows label', (tester) async {
      await pumpWidget(tester);

      expect(find.text('label'), findsOneWidget);
    });

    testWidgets('shows icon', (tester) async {
      await pumpWidget(tester);

      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    });
  });

  group('Interactions', () {
    testWidgets('calls onPressed when pressed', (tester) async {
      var pressed = false;
      await pumpWidget(
        tester,
        onPressed: () {
          pressed = true;
        },
      );

      await tester.tap(find.text('label'));

      expect(pressed, isTrue);
    });
  });

  group('a11y', () {
    testWidgets(
      'has semantics set to provided label '
      'when semanticsLabel is null',
      (tester) async {
        await pumpWidget(tester);

        expect(find.bySemanticsLabel('label'), findsOneWidget);
      },
    );

    testWidgets(
      'has semantics set to provided semanticsLabel',
      (tester) async {
        await pumpWidget(tester, semanticsLabel: 'semantics');

        expect(find.bySemanticsLabel('semantics'), findsOneWidget);
      },
    );
  });
}
