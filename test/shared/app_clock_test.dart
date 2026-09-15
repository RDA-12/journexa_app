import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/shared/app_clock.dart';

class TestClass with AppClockMixin;

void main() {
  group('AppClockMixin', () {
    late TestClass testObj;

    setUp(() {
      testObj = TestClass();
    });

    group('getCurrentDateTime', () {
      test('returns correct DateTime', () {
        final now = DateTime.now();

        withClock(Clock.fixed(now), () {
          final actual = testObj.getCurrentDateTime();

          expect(actual, now);
        });
      });
    });
  });
}
