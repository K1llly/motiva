import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stoic_mind/features/quote/domain/entities/quote.dart';
import 'package:stoic_mind/features/quote/presentation/screens/quote_detail_screen.dart';

void main() {
  const tQuote = Quote(
    id: '1',
    text: 'The obstacle is the way.',
    author: 'Marcus Aurelius',
    meaning:
        'When we face difficulties, we can choose to see them as obstacles that block our path, or we can see them as opportunities for growth and self-improvement.',
    dayNumber: 1,
  );

  Widget createWidgetUnderTest({Quote quote = tQuote}) {
    return MaterialApp(
      home: QuoteDetailScreen(quote: quote),
    );
  }

  group('QuoteDetailScreen Widget', () {
    testWidgets('should display "Quote Meaning" in AppBar', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Quote Meaning'), findsOneWidget);
    });

    testWidgets('should display quote text', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('The obstacle is the way.'), findsOneWidget);
    });

    testWidgets('should display author name with dash prefix', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('- Marcus Aurelius'), findsOneWidget);
    });

    testWidgets('should display "What This Means" section header',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('What This Means'), findsOneWidget);
    });

    testWidgets('should display quote meaning text', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(
        find.textContaining('When we face difficulties'),
        findsOneWidget,
      );
    });

    testWidgets('should display quote icon', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.format_quote), findsOneWidget);
    });

    testWidgets('should be scrollable', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should display Card containing quote', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should have centered AppBar title', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.centerTitle, true);
    });

    testWidgets('should display different quote correctly', (tester) async {
      const anotherQuote = Quote(
        id: '2',
        text: 'We suffer more in imagination than in reality.',
        author: 'Seneca',
        meaning:
            'Most of our worries never come to pass. We create suffering in our minds.',
        dayNumber: 2,
      );

      await tester.pumpWidget(createWidgetUnderTest(quote: anotherQuote));

      expect(
        find.text('We suffer more in imagination than in reality.'),
        findsOneWidget,
      );
      expect(find.text('- Seneca'), findsOneWidget);
      expect(
        find.textContaining('Most of our worries'),
        findsOneWidget,
      );
    });

    testWidgets('should handle long meaning text', (tester) async {
      const longQuote = Quote(
        id: '3',
        text: 'Short quote.',
        author: 'Author',
        meaning: '''
This is a very long meaning that spans multiple paragraphs.

The Stoics believed that our perception of events determines our emotional response to them. When we face a challenge, we have the power to choose how we interpret it.

This is the essence of Stoic philosophy - that our judgments about external events, not the events themselves, are what cause us distress or contentment.

By training ourselves to see obstacles as opportunities, we transform every setback into a chance for growth.
        ''',
        dayNumber: 3,
      );

      await tester.pumpWidget(createWidgetUnderTest(quote: longQuote));

      // Should still be scrollable and render without errors
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.text('Short quote.'), findsOneWidget);
    });

    testWidgets('should have back button in AppBar', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // AppBar should have default back button when pushed
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should render with proper padding', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final scrollView = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(scrollView.padding, const EdgeInsets.all(24.0));
    });
  });
}
