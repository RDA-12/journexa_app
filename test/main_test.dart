import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/main.dart';
import 'package:journexa_app/ui/auth/bloc/auth_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toastification/toastification.dart';

class MockAuthBloc extends Mock implements AuthBloc;

void main() {
  late AuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    whenListen(
      mockAuthBloc,
      const Stream<AuthState>.empty(),
      initialState: const AuthState.initial(),
    );
    when(mockAuthBloc.close).thenAnswer((_) async => {});
  });

  Future<void> pumpWidget(WidgetTester tester) {
    return tester.pumpWidget(
      JournexaApp(
        authBloc: mockAuthBloc,
      ),
    );
  }

  group('Init', () {
    testWidgets('add AuthEvent.subscriptionRequested', (tester) async {
      await pumpWidget(tester);

      verify(() => mockAuthBloc.add(const AuthEvent.subscriptionRequested()))
          .called(1);
    });
  });

  group('Render', () {
    testWidgets('provides ToastificationWrapper', (tester) async {
      await pumpWidget(tester);

      expect(find.byType(ToastificationWrapper), findsOneWidget);
    });

    testWidgets('provides AuthBloc', (tester) async {
      await pumpWidget(tester);

      expect(find.byType(BlocProvider<AuthBloc>), findsOneWidget);
    });
  });
}
