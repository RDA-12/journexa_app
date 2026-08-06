import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/ui/splash/bloc/auth_check_bloc.dart';
import 'package:journexa_app/ui/splash/splash_page.dart';
import 'package:journexa_app/ui/splash/widgets/widgets.dart';
import 'package:mocktail/mocktail.dart';

import '../util.dart';

class MockAuthCheckBloc extends Mock implements AuthCheckBloc {}

void main() {
  late AuthCheckBloc mockAuthCheckBloc;

  setUp(() {
    mockAuthCheckBloc = MockAuthCheckBloc();
    whenListen(
      mockAuthCheckBloc,
      const Stream<AuthCheckState>.empty(),
      initialState: const AuthCheckState.initial(),
    );
    when(mockAuthCheckBloc.close).thenAnswer((_) async {});
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    Map<String, Widget> nextRoutes = const {},
  }) {
    return pumpForPageTest(
      tester,
      locale: const Locale('en'),
      routes: {
        '/': SplashPage(authCheckBloc: mockAuthCheckBloc),
        ...nextRoutes,
      },
    );
  }

  group('Init', () {
    testWidgets(
      'add AuthCheckEvent.started on start',
      (tester) async {
        await pumpWidget(tester);

        verify(
          () => mockAuthCheckBloc.add(
            const AuthCheckEvent.started(),
          ),
        ).called(1);
      },
    );
  });

  group('Render', () {
    testWidgets(
      'shows SplashBox',
      (tester) async {
        await pumpWidget(tester);

        expect(find.byType(SplashBox), findsOneWidget);
      },
    );

    testWidgets(
      'provides AuthCheckBloc',
      (tester) async {
        await pumpWidget(tester);

        expect(find.byType(BlocProvider<AuthCheckBloc>), findsOneWidget);
      },
    );
  });

  group(
    'Side Effect',
    () {
      testWidgets(
        'go to initalize page when authenticated',
        (tester) async {
          whenListen(
            mockAuthCheckBloc,
            Stream.fromIterable([
              const AuthCheckState.loading(),
              const AuthCheckState.authenticated(),
            ]),
          );

          const expectedPage = Scaffold(
            key: ValueKey('initialize'),
          );
          await pumpWidget(tester, nextRoutes: {'/initialize': expectedPage});
          await tester.pumpAndSettle();

          expect(find.byKey(const ValueKey('initialize')), findsOneWidget);
          expect(find.byType(SplashPage), findsNothing);
        },
      );

      testWidgets(
        'go to login page when unauthenticated',
        (tester) async {
          whenListen(
            mockAuthCheckBloc,
            Stream.fromIterable([
              const AuthCheckState.loading(),
              const AuthCheckState.unauthenticated(),
            ]),
          );

          const expectedPage = Scaffold(
            key: ValueKey('login'),
          );
          await pumpWidget(tester, nextRoutes: {'/login': expectedPage});
          await tester.pumpAndSettle();

          expect(find.byKey(const ValueKey('login')), findsOneWidget);
          expect(find.byType(SplashPage), findsNothing);
        },
      );
    },
  );
}
