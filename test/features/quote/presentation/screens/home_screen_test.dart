import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stoic_mind/features/quote/domain/entities/quote.dart';
import 'package:stoic_mind/features/quote/presentation/bloc/quote_bloc.dart';
import 'package:stoic_mind/features/quote/presentation/bloc/quote_event.dart';
import 'package:stoic_mind/features/quote/presentation/bloc/quote_state.dart';
import 'package:stoic_mind/features/quote/presentation/screens/home_screen.dart';
import 'package:stoic_mind/features/streak/domain/entities/streak.dart';
import 'package:stoic_mind/features/streak/presentation/bloc/streak_bloc.dart';
import 'package:stoic_mind/features/streak/presentation/bloc/streak_event.dart';
import 'package:stoic_mind/features/streak/presentation/bloc/streak_state.dart';

class MockQuoteBloc extends MockBloc<QuoteEvent, QuoteState>
    implements QuoteBloc {}

class MockStreakBloc extends MockBloc<StreakEvent, StreakState>
    implements StreakBloc {}

void main() {
  late MockQuoteBloc mockQuoteBloc;
  late MockStreakBloc mockStreakBloc;

  const tQuote = Quote(
    id: '1',
    text: 'The obstacle is the way.',
    author: 'Marcus Aurelius',
    meaning: 'Challenges are opportunities for growth.',
    dayNumber: 1,
  );

  final tStreak = Streak(
    currentStreak: 5,
    longestStreak: 10,
    startDate: DateTime.now(),
    lastActiveDate: DateTime.now(),
    totalQuotesRead: 20,
  );

  setUp(() {
    mockQuoteBloc = MockQuoteBloc();
    mockStreakBloc = MockStreakBloc();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      routes: {
        '/quote-detail': (context) => const Scaffold(body: Text('Detail Screen')),
      },
      home: MultiBlocProvider(
        providers: [
          BlocProvider<QuoteBloc>.value(value: mockQuoteBloc),
          BlocProvider<StreakBloc>.value(value: mockStreakBloc),
        ],
        child: const HomeScreen(),
      ),
    );
  }

  group('HomeScreen Widget', () {
    testWidgets('should display app title "Motiva" in AppBar', (tester) async {
      when(() => mockQuoteBloc.state).thenReturn(const QuoteInitial());
      when(() => mockStreakBloc.state).thenReturn(const StreakInitial());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Motiva'), findsOneWidget);
    });

    testWidgets('should display loading indicator when QuoteInitial',
        (tester) async {
      when(() => mockQuoteBloc.state).thenReturn(const QuoteInitial());
      when(() => mockStreakBloc.state).thenReturn(const StreakInitial());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display loading indicator when QuoteLoading',
        (tester) async {
      when(() => mockQuoteBloc.state).thenReturn(const QuoteLoading());
      when(() => mockStreakBloc.state).thenReturn(const StreakInitial());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display quote when QuoteLoaded', (tester) async {
      when(() => mockQuoteBloc.state).thenReturn(const QuoteLoaded(quote: tQuote));
      when(() => mockStreakBloc.state).thenReturn(StreakLoaded(tStreak));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('The obstacle is the way.'), findsOneWidget);
      expect(find.text('Marcus Aurelius'), findsOneWidget);
    });

    testWidgets('should display "View Meaning" button when QuoteLoaded',
        (tester) async {
      when(() => mockQuoteBloc.state).thenReturn(const QuoteLoaded(quote: tQuote));
      when(() => mockStreakBloc.state).thenReturn(StreakLoaded(tStreak));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('View Meaning'), findsOneWidget);
      expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
    });

    testWidgets('should display "Share" button when QuoteLoaded',
        (tester) async {
      when(() => mockQuoteBloc.state).thenReturn(const QuoteLoaded(quote: tQuote));
      when(() => mockStreakBloc.state).thenReturn(StreakLoaded(tStreak));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Share'), findsOneWidget);
      expect(find.byIcon(Icons.share), findsOneWidget);
    });

    testWidgets('should display error message when QuoteError', (tester) async {
      when(() => mockQuoteBloc.state)
          .thenReturn(const QuoteError('Could not load quote. Please try again.'));
      when(() => mockStreakBloc.state).thenReturn(const StreakInitial());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Could not load quote. Please try again.'), findsOneWidget);
    });

    testWidgets('should display retry button when QuoteError', (tester) async {
      when(() => mockQuoteBloc.state)
          .thenReturn(const QuoteError('Error loading quote'));
      when(() => mockStreakBloc.state).thenReturn(const StreakInitial());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should display error icon when QuoteError', (tester) async {
      when(() => mockQuoteBloc.state)
          .thenReturn(const QuoteError('Error loading quote'));
      when(() => mockStreakBloc.state).thenReturn(const StreakInitial());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should display StreakCounter in AppBar', (tester) async {
      when(() => mockQuoteBloc.state).thenReturn(const QuoteLoaded(quote: tQuote));
      when(() => mockStreakBloc.state).thenReturn(StreakLoaded(tStreak));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('tapping Share button should show bottom sheet', (tester) async {
      when(() => mockQuoteBloc.state).thenReturn(const QuoteLoaded(quote: tQuote));
      when(() => mockStreakBloc.state).thenReturn(StreakLoaded(tStreak));

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Share'));
      await tester.pumpAndSettle();

      expect(find.text('Share Quote'), findsOneWidget);
    });

    testWidgets('tapping View Meaning button should navigate', (tester) async {
      when(() => mockQuoteBloc.state).thenReturn(const QuoteLoaded(quote: tQuote));
      when(() => mockStreakBloc.state).thenReturn(StreakLoaded(tStreak));

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('View Meaning'));
      await tester.pumpAndSettle();

      expect(find.text('Detail Screen'), findsOneWidget);
    });

    testWidgets('tapping Retry should add LoadDailyQuoteEvent', (tester) async {
      when(() => mockQuoteBloc.state)
          .thenReturn(const QuoteError('Error loading quote'));
      when(() => mockStreakBloc.state).thenReturn(const StreakInitial());

      await tester.pumpWidget(createWidgetUnderTest());

      // Clear any previous interactions from initState
      clearInteractions(mockQuoteBloc);

      await tester.tap(find.text('Retry'));
      await tester.pump();

      verify(() => mockQuoteBloc.add(const LoadDailyQuoteEvent())).called(1);
    });

    testWidgets('should have centered AppBar title', (tester) async {
      when(() => mockQuoteBloc.state).thenReturn(const QuoteInitial());
      when(() => mockStreakBloc.state).thenReturn(const StreakInitial());

      await tester.pumpWidget(createWidgetUnderTest());

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.centerTitle, true);
    });
  });
}
