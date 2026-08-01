import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/ui/shared/widgets/loading_indicator.dart';

void main() {
  Future<void> pumpWidget(
    WidgetTester tester, {
    String? semanticsLabel,
    double? size,
  }) async {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LoadingIndicator(
            semanticsLabel: semanticsLabel,
            size: size ?? 24,
          ),
        ),
      ),
    );
  }

  group('Render', () {
    testWidgets(
      'shows CircularProgressIndicator',
      (tester) async {
        await pumpWidget(tester);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'has expected size',
      (tester) async {
        await pumpWidget(tester, size: 16);

        final boxFinder = find.byType(SizedBox);
        final box = tester.widget<SizedBox>(boxFinder);

        expect(box.width, 16);
        expect(box.height, 16);
      },
    );
  });

  group('a11y', () {
    testWidgets(
      'has correct label when semanticsLabel is provided',
      (tester) async {
        final handle = tester.ensureSemantics();
        await pumpWidget(tester, semanticsLabel: 'Loading');

        expect(find.bySemanticsLabel('Loading'), findsOneWidget);

        handle.dispose();
      },
    );
  });
}
