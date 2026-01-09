import 'package:flutter_test/flutter_test.dart';
import 'package:stoic_mind/features/quote/domain/entities/quote.dart';

void main() {
  group('Quote Entity', () {
    const tQuote = Quote(
      id: '1',
      text: 'Test quote text',
      author: 'Test Author',
      meaning: 'Test meaning',
      dayNumber: 1,
    );

    test('should be a valid Quote instance', () {
      expect(tQuote, isA<Quote>());
    });

    test('should have correct properties', () {
      expect(tQuote.id, '1');
      expect(tQuote.text, 'Test quote text');
      expect(tQuote.author, 'Test Author');
      expect(tQuote.meaning, 'Test meaning');
      expect(tQuote.dayNumber, 1);
      expect(tQuote.displayedAt, isNull);
    });

    group('wasDisplayedToday', () {
      test('should return false when displayedAt is null', () {
        expect(tQuote.wasDisplayedToday, false);
      });

      test('should return true when displayed today', () {
        final now = DateTime.now();
        final quoteDisplayedToday = Quote(
          id: '1',
          text: 'Test quote text',
          author: 'Test Author',
          meaning: 'Test meaning',
          dayNumber: 1,
          displayedAt: now,
        );

        expect(quoteDisplayedToday.wasDisplayedToday, true);
      });

      test('should return false when displayed yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final quoteDisplayedYesterday = Quote(
          id: '1',
          text: 'Test quote text',
          author: 'Test Author',
          meaning: 'Test meaning',
          dayNumber: 1,
          displayedAt: yesterday,
        );

        expect(quoteDisplayedYesterday.wasDisplayedToday, false);
      });
    });

    group('Equatable', () {
      test('should return true when comparing two identical quotes', () {
        const quote1 = Quote(
          id: '1',
          text: 'Test',
          author: 'Author',
          meaning: 'Meaning',
          dayNumber: 1,
        );
        const quote2 = Quote(
          id: '1',
          text: 'Test',
          author: 'Author',
          meaning: 'Meaning',
          dayNumber: 1,
        );

        expect(quote1, equals(quote2));
      });

      test('should return false when comparing different quotes', () {
        const quote1 = Quote(
          id: '1',
          text: 'Test',
          author: 'Author',
          meaning: 'Meaning',
          dayNumber: 1,
        );
        const quote2 = Quote(
          id: '2',
          text: 'Different',
          author: 'Author',
          meaning: 'Meaning',
          dayNumber: 1,
        );

        expect(quote1, isNot(equals(quote2)));
      });

      test('props should contain all properties', () {
        expect(tQuote.props, [
          '1',
          'Test quote text',
          'Test Author',
          'Test meaning',
          1,
          null,
        ]);
      });
    });
  });
}
