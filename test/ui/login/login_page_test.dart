import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/ui/login/login_page.dart';
import 'package:journexa_app/ui/login/widgets/widgets.dart';
import 'package:journexa_app/ui/login_button/bloc/login_bloc.dart';
import 'package:journexa_app/ui/login_button/widgets/login_with_google_button.dart';
import 'package:mocktail/mocktail.dart';

import '../util.dart';

class MockLoginBloc extends Mock implements LoginBloc {}

void main() {
  final LoginBloc mockLoginBloc = MockLoginBloc();

  Future<void> pumpPage(
    WidgetTester tester, {
    Map<String, Widget> nextRoutes = const {},
  }) {
    return pumpForPageTest(
      tester,
      locale: const Locale('en'),
      initialLocation: '/login',
      routes: {
        '/login': LoginPage(
          loginBloc: mockLoginBloc,
        ),
        ...nextRoutes,
      },
    );
  }

  setUp(() {
    when(mockLoginBloc.close).thenAnswer((_) async {});
    whenListen(
      mockLoginBloc,
      const Stream<LoginState>.empty(),
      initialState: const LoginState.initial(),
    );
  });

  tearDown(() {
    reset(mockLoginBloc);
  });

  group('Render', () {
    testWidgets(
      'provides LoginBloc',
      (tester) async {
        await pumpPage(tester);

        expect(find.byType(BlocProvider<LoginBloc>), findsOneWidget);
      },
    );

    testWidgets(
      'has LoginWithGoogleButton',
      (tester) async {
        await pumpPage(tester);

        expect(find.byType(LoginWithGoogleButton), findsOneWidget);
      },
    );

    testWidgets(
      'has LoginHeader',
      (tester) async {
        await pumpPage(tester);

        expect(find.byType(LoginHeader), findsOneWidget);
      },
    );
  });

  group('Side Effects', () {
    testWidgets(
      'go to home page when user log in succeeded',
      (tester) async {
        whenListen(
          mockLoginBloc,
          Stream.fromIterable([
            const LoginState.loading(),
            const LoginState.success(),
          ]),
        );

        const expectedPage = Scaffold(key: ValueKey('homepage'));
        await pumpPage(
          tester,
          nextRoutes: {
            '/': expectedPage,
          },
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('homepage')), findsOneWidget);
        expect(find.byType(LoginPage), findsNothing);
      },
    );
  });
}
