import 'package:flutter_test/flutter_test.dart';
import 'package:stoic_mind/features/streak/domain/entities/streak.dart';

void main() {
  group('Streak Entity', () {
    final tNow = DateTime.now();
    final tStreak = Streak(
      currentStreak: 5,
      longestStreak: 10,
      startDate: tNow.subtract(const Duration(days: 30)),
      lastActiveDate: tNow,
      totalQuotesRead: 25,
    );

    test('should be a valid Streak instance', () {
      expect(tStreak, isA<Streak>());
    });

    test('should have correct properties', () {
      expect(tStreak.currentStreak, 5);
      expect(tStreak.longestStreak, 10);
      expect(tStreak.totalQuotesRead, 25);
    });

    group('Streak.empty()', () {
      test('should create streak with all zero values', () {
        final emptyStreak = Streak.empty();

        expect(emptyStreak.currentStreak, 0);
        expect(emptyStreak.longestStreak, 0);
        expect(emptyStreak.totalQuotesRead, 0);
      });

      test('should set startDate to now and lastActiveDate to yesterday', () {
        final before = DateTime.now();
        final emptyStreak = Streak.empty();
        final after = DateTime.now();

        expect(
          emptyStreak.startDate.isAfter(before.subtract(const Duration(seconds: 1))),
          true,
        );
        expect(
          emptyStreak.startDate.isBefore(after.add(const Duration(seconds: 1))),
          true,
        );
        // lastActiveDate should be approximately 1 day before now
        expect(
          emptyStreak.lastActiveDate.isBefore(emptyStreak.startDate),
          true,
        );
        final diff = emptyStreak.startDate.difference(emptyStreak.lastActiveDate);
        expect(diff.inDays, 1);
      });
    });

    group('isActiveOn', () {
      test('should return true when lastActiveDate is today', () {
        final now = DateTime.now();
        final activeStreak = Streak(
          currentStreak: 1,
          longestStreak: 1,
          startDate: now,
          lastActiveDate: now,
          totalQuotesRead: 1,
        );

        expect(activeStreak.isActiveOn(now), true);
      });

      test('should return true when lastActiveDate is yesterday', () {
        final now = DateTime.now();
        final yesterday = now.subtract(const Duration(days: 1));
        final activeStreak = Streak(
          currentStreak: 1,
          longestStreak: 1,
          startDate: yesterday,
          lastActiveDate: yesterday,
          totalQuotesRead: 1,
        );

        expect(activeStreak.isActiveOn(now), true);
      });

      test('should return false when lastActiveDate is 2+ days ago', () {
        final now = DateTime.now();
        final twoDaysAgo = now.subtract(const Duration(days: 2));
        final inactiveStreak = Streak(
          currentStreak: 1,
          longestStreak: 1,
          startDate: twoDaysAgo,
          lastActiveDate: twoDaysAgo,
          totalQuotesRead: 1,
        );

        expect(inactiveStreak.isActiveOn(now), false);
      });
    });

    group('daysSinceStartOn', () {
      test('should return 1 when started today', () {
        final now = DateTime.now();
        final todayStreak = Streak(
          currentStreak: 1,
          longestStreak: 1,
          startDate: now,
          lastActiveDate: now,
          totalQuotesRead: 1,
        );

        expect(todayStreak.daysSinceStartOn(now), 1);
      });

      test('should return correct days since start', () {
        final now = DateTime.now();
        const daysAgo = 10;
        final pastStreak = Streak(
          currentStreak: 1,
          longestStreak: 1,
          startDate: now.subtract(const Duration(days: daysAgo)),
          lastActiveDate: now,
          totalQuotesRead: 1,
        );

        expect(pastStreak.daysSinceStartOn(now), daysAgo + 1);
      });
    });

    group('Equatable', () {
      test('should return true when comparing identical streaks', () {
        final streak1 = Streak(
          currentStreak: 5,
          longestStreak: 10,
          startDate: tNow,
          lastActiveDate: tNow,
          totalQuotesRead: 25,
        );
        final streak2 = Streak(
          currentStreak: 5,
          longestStreak: 10,
          startDate: tNow,
          lastActiveDate: tNow,
          totalQuotesRead: 25,
        );

        expect(streak1, equals(streak2));
      });

      test('should return false when comparing different streaks', () {
        final streak1 = Streak(
          currentStreak: 5,
          longestStreak: 10,
          startDate: tNow,
          lastActiveDate: tNow,
          totalQuotesRead: 25,
        );
        final streak2 = Streak(
          currentStreak: 3,
          longestStreak: 10,
          startDate: tNow,
          lastActiveDate: tNow,
          totalQuotesRead: 25,
        );

        expect(streak1, isNot(equals(streak2)));
      });

      test('props should contain all properties', () {
        expect(tStreak.props.length, 5);
        expect(tStreak.props, contains(5)); // currentStreak
        expect(tStreak.props, contains(10)); // longestStreak
        expect(tStreak.props, contains(25)); // totalQuotesRead
      });
    });
  });
}
