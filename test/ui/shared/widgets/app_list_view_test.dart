import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/ui/shared/widgets/app_list_view.dart';

import '../../util.dart';

void main() {
  final items = List.generate(5, (index) => '$index');

  Future<void> pumpWidget(
    WidgetTester tester, {
    bool? isScrollable,
  }) {
    return pumpForWidgetTest(
      tester,
      locale: const Locale('en'),
      widget: AppListView(
        isScrollable: isScrollable ?? true,
        items: items,
        itemBuilder: (context, index) {
          final item = items[index];
          return Text(item);
        },
      ),
    );
  }

  group('Render', () {
    testWidgets(
      'shows all items in Widget from itemBuilder',
      (tester) async {
        await pumpWidget(tester);
        await tester.pumpAndSettle();

        expect(find.byType(Text).evaluate(), hasLength(items.length));
        for (var i = 0; i < items.length; i++) {
          expect(find.text(items[i]), findsOneWidget);
        }
      },
    );

    testWidgets(
      'set shrinkWrap to true and physics to NeverScrollableScrollPhysics '
      'when isScrollable is false',
      (tester) async {
        await pumpWidget(tester, isScrollable: false);

        final finder = find.byType(ListView);
        expect(finder, findsOneWidget);
        final widget = tester.widget<ListView>(finder);
        expect(widget.shrinkWrap, isTrue);
        expect(widget.physics, const NeverScrollableScrollPhysics());
      },
    );
  });
}
