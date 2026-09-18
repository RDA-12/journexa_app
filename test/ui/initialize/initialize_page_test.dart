import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:journexa_app/ui/initialize/bloc/initialize_bloc.dart';
import 'package:journexa_app/ui/initialize/initialize_page.dart';
import 'package:journexa_app/ui/initialize/widgets/initializing_box.dart';
import 'package:mocktail/mocktail.dart';

import '../util.dart';

class MockInitializeBloc extends Mock implements InitializeBloc;

void main() {
  late InitializeBloc mockInitializeBloc;

  setUp(() {
    mockInitializeBloc = MockInitializeBloc();
    whenListen(
      mockInitializeBloc,
      const Stream<InitializeState>.empty(),
      initialState: const InitializeState.initial(),
    );
    when(mockInitializeBloc.close).thenAnswer((_) async {});
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    List<RouteBase> nextRoutes = const [],
  }) {
    return pumpForPageTest(
      tester,
      initialLocation: '/initialize',
      routes: [
        GoRoute(
          path: '/initialize',
          builder: (context, state) => InitializePage(
            initializeBloc: mockInitializeBloc,
          ),
        ),
        ...nextRoutes,
      ],
      locale: const Locale('en'),
    );
  }

  group('Init', () {
    testWidgets('add InitializeEvent.initialize on start', (tester) async {
      await pumpWidget(tester);

      verify(() => mockInitializeBloc.add(const InitializeEvent.initialize()))
          .called(1);
    });
  });

  group('Render', () {
    testWidgets('provides InitializeBloc', (tester) async {
      await pumpWidget(tester);

      expect(find.byType(BlocProvider<InitializeBloc>), findsOneWidget);
    });

    testWidgets('has InitializingBox', (tester) async {
      await pumpWidget(tester);

      expect(find.byType(InitializingBox), findsOneWidget);
    });
  });

  group('Side Effects', () {
    testWidgets('go to home page when initialization succeeded', (
      tester,
    ) async {
      whenListen(
        mockInitializeBloc,
        Stream.fromIterable([
          const InitializeState.loading(),
          const InitializeState.initialized(),
        ]),
      );

      const expectedPage = Scaffold(key: ValueKey('homepage'));
      await pumpWidget(
        tester,
        nextRoutes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => expectedPage,
          ),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('homepage')), findsOneWidget);
      expect(find.byType(InitializePage), findsNothing);
    });
  });
}
