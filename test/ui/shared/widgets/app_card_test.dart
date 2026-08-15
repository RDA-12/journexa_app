import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/ui/shared/widgets/app_card.dart';

import '../../util.dart';

void main() {
  Future<void> pumpWidget(WidgetTester tester) async {
    return pumpForWidgetTest(
      tester,
      locale: const Locale('en'),
      widget: AppCard(
        leading: Container(
          key: const ValueKey('leading'),
        ),
        child: Container(
          key: const ValueKey('child'),
        ),
      ),
    );
  }

  group('Render', () {
    testWidgets(
      'shows leading when provided',
      (tester) async {
        await pumpWidget(tester);

        expect(find.byKey(const ValueKey('leading')), findsOneWidget);
        expect(find.byKey(const ValueKey('child')), findsOneWidget);
      },
    );

    testWidgets(
      'shows child ',
      (tester) async {
        await pumpWidget(tester);

        expect(find.byKey(const ValueKey('child')), findsOneWidget);
      },
    );
  });
}
