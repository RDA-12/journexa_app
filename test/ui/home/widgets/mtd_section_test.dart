import 'package:bloc_test/bloc_test.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/ui/home/bloc/home_bloc.dart';
import 'package:journexa_app/ui/home/widgets/mtd_card.dart';
import 'package:journexa_app/ui/home/widgets/mtd_section.dart';
import 'package:journexa_app/ui/shared/l10n/app_localizations.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';
import 'package:mocktail/mocktail.dart';

import '../../util.dart';

class MockHomeBloc extends Mock implements HomeBloc;

final expectedTranslations = {
  'en': {
    'loadingSemantics': 'Loading net balance this month',
    'exception': 'Internal exception error',
  },
  'id': {
    'loadingSemantics': 'Memuat data saldo bersih bulan ini',
    'exception': 'Terjadi kesalahan internal',
  },
};

void main() {
  final totalIncome = Decimal.fromInt(100000);
  final totalExpense = Decimal.fromInt(50000);
  final netBalance = Decimal.fromInt(50000);

  late HomeBloc mockHomeBloc;

  setUp(() {
    mockHomeBloc = MockHomeBloc();
    whenListen(
      mockHomeBloc,
      const Stream<HomeState>.empty(),
      initialState: HomeState(),
    );
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) {
    return pumpForWidgetTest(
      tester,
      locale: locale,
      widget: BlocProvider.value(
        value: mockHomeBloc,
        child: const MTDSection(),
      ),
    );
  }

  group('Render', () {
    testWidgets('shows LoadingIndicator when state is loading', (tester) async {
      whenListen(
        mockHomeBloc,
        const Stream<HomeState>.empty(),
        initialState: HomeState(
          mtdData: HomeMTDDataUIModel(
            totalIncome: Decimal.zero,
            totalExpense: Decimal.zero,
            status: HomeUIStatus.loading,
          ),
        ),
      );

      await pumpWidget(tester);

      expect(find.byType(LoadingIndicator), findsOneWidget);
    });

    for (final locale in AppLocalizations.supportedLocales) {
      final translations = expectedTranslations[locale.languageCode]!;

      final expectedDescription = translations['exception']!;
      testWidgets('shows AppExceptionBox when state is failure '
          'for ${locale.languageCode}', (tester) async {
        whenListen(
          mockHomeBloc,
          const Stream<HomeState>.empty(),
          initialState: HomeState(
            mtdData: HomeMTDDataUIModel(
              totalIncome: Decimal.zero,
              totalExpense: Decimal.zero,
              status: HomeUIStatus.failure,
              exception: AppException.test(),
            ),
          ),
        );

        await pumpWidget(tester, locale: locale);

        final finder = find.byType(AppExceptionBox);
        expect(finder, findsOneWidget);

        final widget = tester.widget<AppExceptionBox>(finder);
        expect(widget.description, expectedDescription);
      });
    }

    testWidgets('shows MTDCard for income with correct data '
        'when state is loaded', (tester) async {
      whenListen(
        mockHomeBloc,
        const Stream<HomeState>.empty(),
        initialState: HomeState(
          mtdData: HomeMTDDataUIModel(
            totalIncome: totalIncome,
            totalExpense: totalExpense,
            status: HomeUIStatus.loaded,
          ),
        ),
      );

      await pumpWidget(tester);

      final finder = find.byWidgetPredicate(
        (widget) => widget is MTDCard && widget.type == MTDCardType.income,
      );
      expect(finder, findsOneWidget);

      final widget = tester.widget<MTDCard>(finder);
      expect(widget.data, totalIncome);
    });

    testWidgets('shows MTDCard for expense with correct data '
        'when state is loaded', (tester) async {
      whenListen(
        mockHomeBloc,
        const Stream<HomeState>.empty(),
        initialState: HomeState(
          mtdData: HomeMTDDataUIModel(
            totalIncome: totalIncome,
            totalExpense: totalExpense,
            status: HomeUIStatus.loaded,
          ),
        ),
      );

      await pumpWidget(tester);

      final finder = find.byWidgetPredicate(
        (widget) => widget is MTDCard && widget.type == MTDCardType.expense,
      );
      expect(finder, findsOneWidget);

      final widget = tester.widget<MTDCard>(finder);
      expect(widget.data, totalExpense);
    });

    testWidgets('shows MTDCard for net balance with correct data '
        'when state is loaded', (tester) async {
      whenListen(
        mockHomeBloc,
        const Stream<HomeState>.empty(),
        initialState: HomeState(
          mtdData: HomeMTDDataUIModel(
            totalIncome: totalIncome,
            totalExpense: totalExpense,
            status: HomeUIStatus.loaded,
          ),
        ),
      );

      await pumpWidget(tester);

      final finder = find.byWidgetPredicate(
        (widget) => widget is MTDCard && widget.type == MTDCardType.net,
      );
      expect(finder, findsOneWidget);

      final widget = tester.widget<MTDCard>(finder);
      expect(widget.data, netBalance);
    });
  });

  group('a11y', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final translations = expectedTranslations[locale.languageCode]!;

      final loadingSemantics = translations['loadingSemantics']!;
      testWidgets('has correct semantics when state is loading '
          'for ${locale.languageCode}', (tester) async {
        whenListen(
          mockHomeBloc,
          const Stream<HomeState>.empty(),
          initialState: HomeState(
            mtdData: HomeMTDDataUIModel(
              totalIncome: totalIncome,
              totalExpense: totalExpense,
              status: HomeUIStatus.loading,
            ),
          ),
        );

        await pumpWidget(tester, locale: locale);

        expect(find.bySemanticsLabel(loadingSemantics), findsOneWidget);
      });
    }
  });
}
