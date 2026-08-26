import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/ui/income_categories/widgets/income_category_tile.dart';

import '../../util.dart';

void main() {
  final category = IncomeCategory(
    id: 'id',
    name: 'name',
    icon: 'icon',
    account: Account.user(
      parent: SystemDefinedAccount.rootRevenue,
      name: 'name',
      currentChildrenCount: 0,
    ),
  );

  Future<void> pumpWidget(WidgetTester tester, {VoidCallback? onPressed}) {
    return pumpForWidgetTest(
      tester,
      locale: const Locale('en'),
      widget: IncomeCategoryTile(
        category: category,
        onPressed: onPressed,
      ),
    );
  }

  group('Render', () {
    testWidgets(
      'shows correct category name',
      (tester) async {
        await pumpWidget(tester);

        expect(find.text(category.name), findsOneWidget);
      },
    );
  });

  group('Interactions', () {
    testWidgets(
      'calls onPressed when pressed',
      (tester) async {
        var pressed = false;

        await pumpWidget(
          tester,
          onPressed: () {
            pressed = true;
          },
        );

        await tester.tap(find.byType(IncomeCategoryTile));
        await tester.pump();

        expect(pressed, isTrue);
      },
    );
  });

  group('a11y', () {
    testWidgets(
      'has correct category name semantically',
      (tester) async {
        await pumpWidget(tester);

        expect(find.bySemanticsLabel(category.name), findsOneWidget);
      },
    );
  });
}
