import 'package:flutter_test/flutter_test.dart';
import 'package:stoic_mind/core/utils/date_utils.dart';

void main() {
  group('AppDateUtils', () {
    group('calculateDayNumber', () {
      test('should return 1 when install date is today', () {
        final today = DateTime.now();
        final result = AppDateUtils.calculateDayNumber(today);
        expect(result, 1);
      });

      test('should return 2 when install date was yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final result = AppDateUtils.calculateDayNumber(yesterday);
        expect(result, 2);
      });

      test('should return correct day number for past install date', () {
        final tenDaysAgo = DateTime.now().subtract(const Duration(days: 10));
        final result = AppDateUtils.calculateDayNumber(tenDaysAgo);
        expect(result, 11);
      });

      test('should handle different times on the same day', () {
        final now = DateTime.now();
        final earlierToday = DateTime(now.year, now.month, now.day, 1, 0, 0);
        final laterToday = DateTime(now.year, now.month, now.day, 23, 59, 59);

        // Both should return 1 since it's the same day
        expect(AppDateUtils.calculateDayNumber(earlierToday), 1);
        expect(AppDateUtils.calculateDayNumber(laterToday), 1);
      });
    });

    group('getTimeUntilNextQuote', () {
      test('should return positive duration', () {
        final duration = AppDateUtils.getTimeUntilNextQuote();
        expect(duration.isNegative, false);
      });

      test('should return less than 24 hours', () {
        final duration = AppDateUtils.getTimeUntilNextQuote();
        expect(duration.inHours, lessThan(24));
      });
    });

    group('shouldShowNewQuote', () {
      test('should return true when lastQuoteDate is null', () {
        final result = AppDateUtils.shouldShowNewQuote(null);
        expect(result, true);
      });

      test('should return false when lastQuoteDate is today', () {
        final today = DateTime.now();
        final result = AppDateUtils.shouldShowNewQuote(today);
        expect(result, false);
      });

      test('should return true when lastQuoteDate was yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final result = AppDateUtils.shouldShowNewQuote(yesterday);
        expect(result, true);
      });

      test('should return true when lastQuoteDate was in the past', () {
        final pastDate = DateTime.now().subtract(const Duration(days: 7));
        final result = AppDateUtils.shouldShowNewQuote(pastDate);
        expect(result, true);
      });
    });

    group('formatDuration', () {
      test('should format hours and minutes correctly', () {
        const duration = Duration(hours: 12, minutes: 30);
        final result = AppDateUtils.formatDuration(duration);
        expect(result, '12h 30m');
      });

      test('should format only minutes when hours is 0', () {
        const duration = Duration(minutes: 45);
        final result = AppDateUtils.formatDuration(duration);
        expect(result, '45m');
      });

      test('should format hours with 0 minutes', () {
        const duration = Duration(hours: 5);
        final result = AppDateUtils.formatDuration(duration);
        expect(result, '5h 0m');
      });

      test('should format 0 minutes correctly', () {
        const duration = Duration.zero;
        final result = AppDateUtils.formatDuration(duration);
        expect(result, '0m');
      });
    });

    group('isSameDay', () {
      test('should return true for same day', () {
        final date1 = DateTime(2024, 1, 15, 10, 30);
        final date2 = DateTime(2024, 1, 15, 22, 45);
        final result = AppDateUtils.isSameDay(date1, date2);
        expect(result, true);
      });

      test('should return false for different days', () {
        final date1 = DateTime(2024, 1, 15);
        final date2 = DateTime(2024, 1, 16);
        final result = AppDateUtils.isSameDay(date1, date2);
        expect(result, false);
      });

      test('should return false for same day different month', () {
        final date1 = DateTime(2024, 1, 15);
        final date2 = DateTime(2024, 2, 15);
        final result = AppDateUtils.isSameDay(date1, date2);
        expect(result, false);
      });

      test('should return false for same day different year', () {
        final date1 = DateTime(2024, 1, 15);
        final date2 = DateTime(2025, 1, 15);
        final result = AppDateUtils.isSameDay(date1, date2);
        expect(result, false);
      });
    });

    group('startOfDay', () {
      test('should return date with time set to midnight', () {
        final date = DateTime(2024, 1, 15, 14, 30, 45);
        final result = AppDateUtils.startOfDay(date);

        expect(result.year, 2024);
        expect(result.month, 1);
        expect(result.day, 15);
        expect(result.hour, 0);
        expect(result.minute, 0);
        expect(result.second, 0);
      });

      test('should handle midnight input correctly', () {
        final date = DateTime(2024, 1, 15);
        final result = AppDateUtils.startOfDay(date);

        expect(result, date);
      });
    });
  });
}
