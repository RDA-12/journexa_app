import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/ui/home/bloc/home_bloc.dart';
import 'package:journexa_app/ui/home/home_page.dart';
import 'package:journexa_app/ui/home/widgets/wallets_home_carousel.dart';
import 'package:mocktail/mocktail.dart';

import '../util.dart';

class MockHomeBloc extends Mock implements HomeBloc {}

void main() {
  late HomeBloc mockHomeBloc;

  setUp(() {
    mockHomeBloc = MockHomeBloc();
    whenListen(
      mockHomeBloc,
      const Stream<HomeState>.empty(),
      initialState: HomeState(),
    );
    when(mockHomeBloc.close).thenAnswer((_) async {});
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    Map<String, Widget> nextRoutes = const {},
  }) {
    return pumpForPageTest(
      tester,
      initialLocation: '/home',
      routes: {
        '/home': HomePage(
          homeBloc: mockHomeBloc,
        ),
        ...nextRoutes,
      },
      locale: locale,
    );
  }

  group('Init', () {
    testWidgets(
      'add HomeEvent.subscriptionsRequested event on start',
      (tester) async {
        await pumpWidget(tester);

        verify(
          () => mockHomeBloc.add(
            const HomeEvent.subscriptionsRequested(),
          ),
        ).called(1);
      },
    );

    testWidgets(
      'add HomeEvent.mtdSubscriptionRequested event on start '
      'with current date',
      (tester) async {
        final now = DateTime.now();
        await withClock(Clock.fixed(now), () async {
          await pumpWidget(tester);

          verify(
            () => mockHomeBloc.add(
              HomeEvent.mtdSubscriptionRequested(targetDate: now),
            ),
          ).called(1);
        });
      },
    );
  });

  group('Render', () {
    testWidgets(
      'provides HomeBloc',
      (tester) async {
        await pumpWidget(tester);

        expect(find.byType(BlocProvider<HomeBloc>), findsOneWidget);
      },
    );

    testWidgets(
      'has WalletsHomeCarousel',
      (tester) async {
        await pumpWidget(tester);

        expect(find.byType(WalletsHomeCarousel), findsOneWidget);
      },
    );
  });
}
