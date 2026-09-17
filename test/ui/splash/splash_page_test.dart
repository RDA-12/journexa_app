import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/user.dart';
import 'package:journexa_app/ui/auth/bloc/auth_bloc.dart';
import 'package:journexa_app/ui/splash/splash_page.dart';
import 'package:journexa_app/ui/splash/widgets/widgets.dart';
import 'package:mocktail/mocktail.dart';

import '../util.dart';

class MockAuthBloc extends Mock implements AuthBloc;

void main() {
  const user = User(id: 'id', name: 'name');

  late AuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    whenListen(
      mockAuthBloc,
      const Stream<AuthState>.empty(),
      initialState: const AuthState.initial(),
    );
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    Map<String, Widget> nextRoutes = const {},
  }) {
    return pumpForPageTest(
      tester,
      locale: const Locale('en'),
      routes: {
        '/': BlocProvider.value(
          value: mockAuthBloc,
          child: const SplashPage(),
        ),
        ...nextRoutes,
      },
    );
  }

  group('Render', () {
    testWidgets('shows SplashBox', (tester) async {
      await pumpWidget(tester);

      expect(find.byType(SplashBox), findsOneWidget);
    });

    testWidgets('provides AuthBloc', (tester) async {
      await pumpWidget(tester);

      expect(find.byType(BlocProvider<AuthBloc>), findsOneWidget);
    });
  });

  group('Side Effect', () {
    testWidgets('go to initalize page when authenticated', (tester) async {
      whenListen(
        mockAuthBloc,
        Stream.fromIterable([
          const AuthState.loading(),
          const AuthState.authenticated(user),
        ]),
      );

      const expectedPage = Scaffold(key: ValueKey('initialize'));
      await pumpWidget(tester, nextRoutes: {'/initialize': expectedPage});
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('initialize')), findsOneWidget);
      expect(find.byType(SplashPage), findsNothing);
    });

    testWidgets('go to login page when unauthenticated', (tester) async {
      whenListen(
        mockAuthBloc,
        Stream.fromIterable([
          const AuthState.loading(),
          const AuthState.unauthenticated(),
        ]),
      );

      const expectedPage = Scaffold(key: ValueKey('login'));
      await pumpWidget(tester, nextRoutes: {'/login': expectedPage});
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('login')), findsOneWidget);
      expect(find.byType(SplashPage), findsNothing);
    });
  });
}
