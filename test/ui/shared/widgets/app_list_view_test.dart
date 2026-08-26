import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/ui/shared/widgets/app_list_view.dart';

import '../../util.dart';

void main() {
  final items = List.generate(5, (index) => '$index');

  Future<void> pumpWidget(WidgetTester tester) {
    return pumpForWidgetTest(
      tester,
      locale: const Locale('en'),
      widget: AppListView(
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
  });
}
