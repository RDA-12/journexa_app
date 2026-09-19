import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/ui/shell/widgets/widgets.dart';

import '../../util.dart';

void main() {
  Future<void> pumpWidget(WidgetTester tester) {
    return pumpForWidgetTest(
      tester,
      locale: const Locale('en'),
      widget: AppExpandableFab(
        icon: const Icon(Icons.add_rounded),
        actions: [
          AppFabAction(
            label: 'label-1',
            icon: const Icon(Icons.abc),
            onPressed: () {},
          ),
          AppFabAction(
            label: 'label-2',
            icon: const Icon(Icons.abc),
            onPressed: () {},
          ),
          AppFabAction(
            label: 'label-3',
            icon: const Icon(Icons.abc),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  group('Render', () {
    testWidgets('shows ExpandableFab with correct config', (tester) async {
      await pumpWidget(tester);

      final finder = find.byType(ExpandableFab);
      expect(finder, findsOneWidget);
      final widget = tester.widget<ExpandableFab>(finder);
      expect(widget.type, ExpandableFabType.up);
      expect(widget.distance, 4);
    });

    testWidgets('shows correct icon', (tester) async {
      await pumpWidget(tester);

      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    });
  });

  group('Interactions', () {
    testWidgets('shows children when pressed', (tester) async {
      await pumpWidget(tester);

      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      for (var i = 1; i <= 3; i++) {
        final finder = find.text('label-$i');
        expect(finder, findsOneWidget);
      }
    });
  });
}
