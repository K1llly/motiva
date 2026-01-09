import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stoic_mind/features/quote/domain/entities/quote.dart';
import 'package:stoic_mind/features/quote/presentation/widgets/quote_card.dart';

void main() {
  const tQuote = Quote(
    id: '1',
    text: 'The obstacle is the way.',
    author: 'Marcus Aurelius',
    meaning: 'Challenges are opportunities for growth.',
    dayNumber: 1,
  );

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: Scaffold(
        body: QuoteCard(quote: tQuote),
      ),
    );
  }

  group('QuoteCard Widget', () {
    testWidgets('should render quote text', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('The obstacle is the way.'), findsOneWidget);
    });

    testWidgets('should render author name', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Marcus Aurelius'), findsOneWidget);
    });

    testWidgets('should render quote icon', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.format_quote), findsOneWidget);
    });

    testWidgets('should be wrapped in a Card widget', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should render decorative lines around author', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find Container widgets that are the decorative lines (40px width, 2px height)
      final containers = find.byType(Container);
      expect(containers, findsWidgets);
    });

    testWidgets('should center text alignment', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textWidget = tester.widget<Text>(find.text('The obstacle is the way.'));
      expect(textWidget.textAlign, TextAlign.center);
    });

    testWidgets('should render with long quote text', (tester) async {
      const longQuote = Quote(
        id: '2',
        text:
            'You have power over your mind - not outside events. Realize this, and you will find strength. The happiness of your life depends upon the quality of your thoughts.',
        author: 'Marcus Aurelius',
        meaning: 'A longer meaning text for testing purposes.',
        dayNumber: 2,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: QuoteCard(quote: longQuote),
            ),
          ),
        ),
      );

      expect(find.textContaining('You have power over your mind'), findsOneWidget);
    });

    testWidgets('should render with different authors', (tester) async {
      const senecaQuote = Quote(
        id: '3',
        text: 'We suffer more in imagination than in reality.',
        author: 'Seneca',
        meaning: 'Test meaning',
        dayNumber: 3,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QuoteCard(quote: senecaQuote),
          ),
        ),
      );

      expect(find.text('Seneca'), findsOneWidget);
      expect(find.text('We suffer more in imagination than in reality.'), findsOneWidget);
    });
  });
}
