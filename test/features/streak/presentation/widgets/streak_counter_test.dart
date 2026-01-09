import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stoic_mind/features/streak/domain/entities/streak.dart';
import 'package:stoic_mind/features/streak/presentation/bloc/streak_bloc.dart';
import 'package:stoic_mind/features/streak/presentation/bloc/streak_event.dart';
import 'package:stoic_mind/features/streak/presentation/bloc/streak_state.dart';
import 'package:stoic_mind/features/streak/presentation/widgets/streak_counter.dart';

class MockStreakBloc extends MockBloc<StreakEvent, StreakState>
    implements StreakBloc {}

void main() {
  late MockStreakBloc mockStreakBloc;

  setUp(() {
    mockStreakBloc = MockStreakBloc();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          actions: [
            BlocProvider<StreakBloc>.value(
              value: mockStreakBloc,
              child: const StreakCounter(),
            ),
          ],
        ),
      ),
    );
  }

  group('StreakCounter Widget', () {
    testWidgets('should display 0 when state is StreakInitial', (tester) async {
      when(() => mockStreakBloc.state).thenReturn(const StreakInitial());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('should display 0 when state is StreakLoading', (tester) async {
      when(() => mockStreakBloc.state).thenReturn(const StreakLoading());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('should display streak count when state is StreakLoaded',
        (tester) async {
      final streak = Streak(
        currentStreak: 7,
        longestStreak: 14,
        startDate: DateTime.now(),
        lastActiveDate: DateTime.now(),
        totalQuotesRead: 30,
      );

      when(() => mockStreakBloc.state).thenReturn(StreakLoaded(streak));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('should display fire icon', (tester) async {
      when(() => mockStreakBloc.state).thenReturn(const StreakInitial());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
    });

    testWidgets('should display 0 when state is StreakError', (tester) async {
      when(() => mockStreakBloc.state)
          .thenReturn(const StreakError('Error loading streak'));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('should display large streak numbers correctly', (tester) async {
      final streak = Streak(
        currentStreak: 365,
        longestStreak: 365,
        startDate: DateTime.now().subtract(const Duration(days: 365)),
        lastActiveDate: DateTime.now(),
        totalQuotesRead: 365,
      );

      when(() => mockStreakBloc.state).thenReturn(StreakLoaded(streak));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('365'), findsOneWidget);
    });

    testWidgets('should be wrapped in a Container with decoration',
        (tester) async {
      when(() => mockStreakBloc.state).thenReturn(const StreakInitial());

      await tester.pumpWidget(createWidgetUnderTest());

      // Find Container widget
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should update when bloc state changes', (tester) async {
      final initialStreak = Streak(
        currentStreak: 5,
        longestStreak: 10,
        startDate: DateTime.now(),
        lastActiveDate: DateTime.now(),
        totalQuotesRead: 20,
      );

      final updatedStreak = Streak(
        currentStreak: 6,
        longestStreak: 10,
        startDate: DateTime.now(),
        lastActiveDate: DateTime.now(),
        totalQuotesRead: 21,
      );

      whenListen(
        mockStreakBloc,
        Stream.fromIterable([
          StreakLoaded(initialStreak),
          StreakLoaded(updatedStreak),
        ]),
        initialState: StreakLoaded(initialStreak),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.text('5'), findsOneWidget);

      await tester.pump();
      expect(find.text('6'), findsOneWidget);
    });

    testWidgets('should have Row with minimum size', (tester) async {
      when(() => mockStreakBloc.state).thenReturn(const StreakInitial());

      await tester.pumpWidget(createWidgetUnderTest());

      final row = tester.widget<Row>(find.byType(Row).first);
      expect(row.mainAxisSize, MainAxisSize.min);
    });
  });
}
