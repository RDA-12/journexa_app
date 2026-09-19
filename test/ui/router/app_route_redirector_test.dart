import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:journexa_app/domain/entities/user.dart';
import 'package:journexa_app/ui/auth/bloc/auth_bloc.dart';
import 'package:journexa_app/ui/router/router.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';
import 'package:mocktail/mocktail.dart';

import '../util.dart';

class MockGoRouterState extends Mock implements GoRouterState;
class MockAuthBloc extends Mock implements AuthBloc;

class AppRouteRedirectorTester extends StatefulWidget {
  const new({
    required this.redirector,
    required this.state,
    super.key,
  });

  final GoRouterState state;
  final AppRouteRedirector redirector;

  @override
  State<AppRouteRedirectorTester> createState() =>
      _AppRouteRedirectorTesterState();
}

class _AppRouteRedirectorTesterState extends State<AppRouteRedirectorTester> {
  String? _nextLocation;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(_nextLocation ?? 'null'),
        AppButton(
          onPressed: () {
            final result = widget.redirector.maybeRedirect(
              context,
              widget.state,
            );
            setState(() {
              _nextLocation = result;
            });
          },
          label: 'CHECK',
        ),
      ],
    );
  }
}

void main() {
  const user = User(id: 'id', name: 'name');

  late GoRouterState mockGoRouterState;
  late AuthBloc mockAuthBloc;

  setUp(() {
    mockGoRouterState = MockGoRouterState();
    when(() => mockGoRouterState.matchedLocation).thenReturn('/');

    mockAuthBloc = MockAuthBloc();
    whenListen(
      mockAuthBloc,
      const Stream<AuthState>.empty(),
      initialState: const AuthState.initial(),
    );
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    required AppRouteRedirector redirector,
  }) {
    return pumpForWidgetTest(
      tester,
      locale: const Locale('en'),
      widget: BlocProvider.value(
        value: mockAuthBloc,
        child: AppRouteRedirectorTester(
          redirector: redirector,
          state: mockGoRouterState,
        ),
      ),
    );
  }

  Future<void> checkRedirector(WidgetTester tester) async {
    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();
  }

  group('AppAuthRouteRedirector', () {
    late AppAuthRouteRedirector authRedirector;

    setUp(() {
      authRedirector = const AppAuthRouteRedirector();
    });

    testWidgets(
      'redirect user to login when unauthenticated '
      'and user not go to login page',
      (tester) async {
        when(() => mockAuthBloc.state)
            .thenReturn(const AuthState.unauthenticated());
        await pumpWidget(tester, redirector: authRedirector);

        await checkRedirector(tester);

        expect(find.text(const LoginRoute().location), findsOneWidget);
      },
    );

    testWidgets(
      'not redirect user when unauthenticated '
      'and user go to login page',
      (tester) async {
        when(() => mockGoRouterState.matchedLocation)
            .thenReturn(const LoginRoute().location);
        when(() => mockAuthBloc.state)
            .thenReturn(const AuthState.unauthenticated());
        await pumpWidget(tester, redirector: authRedirector);

        await checkRedirector(tester);

        expect(find.text('null'), findsOneWidget);
      },
    );

    testWidgets(
      'redirect user to home when authenticated '
      'and user go to login page',
      (tester) async {
        when(() => mockGoRouterState.matchedLocation)
            .thenReturn(const LoginRoute().location);
        when(() => mockAuthBloc.state)
            .thenReturn(const AuthState.authenticated(user));
        await pumpWidget(tester, redirector: authRedirector);

        await checkRedirector(tester);

        expect(find.text(const HomeRoute().location), findsOneWidget);
      },
    );

    testWidgets(
      'redirect user to home when authenticated '
      'and user go to splash page',
      (tester) async {
        when(() => mockGoRouterState.matchedLocation)
            .thenReturn(const SplashRoute().location);
        when(() => mockAuthBloc.state)
            .thenReturn(const AuthState.authenticated(user));
        await pumpWidget(tester, redirector: authRedirector);

        await checkRedirector(tester);

        expect(find.text(const HomeRoute().location), findsOneWidget);
      },
    );

    testWidgets(
      'not redirect user when authenticated '
      'and user not go to login page',
      (tester) async {
        when(() => mockAuthBloc.state)
            .thenReturn(const AuthState.authenticated(user));
        await pumpWidget(tester, redirector: authRedirector);

        await checkRedirector(tester);

        expect(find.text('null'), findsOneWidget);
      },
    );
  });
}
