import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stoic_mind/features/quote/presentation/widgets/quote_author.dart';

void main() {
  Widget createWidgetUnderTest({String author = 'Marcus Aurelius'}) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: QuoteAuthor(author: author),
        ),
      ),
    );
  }

  group('QuoteAuthor Widget', () {
    testWidgets('should render author name', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Marcus Aurelius'), findsOneWidget);
    });

    testWidgets('should render decorative lines', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Should have Container widgets for the decorative lines
      final containers = find.byType(Container);
      expect(containers, findsWidgets);
    });

    testWidgets('should be centered in a Row', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final row = tester.widget<Row>(find.byType(Row).first);
      expect(row.mainAxisAlignment, MainAxisAlignment.center);
    });

    testWidgets('should render different author names', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(author: 'Seneca'));

      expect(find.text('Seneca'), findsOneWidget);
    });

    testWidgets('should render with long author name', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(author: 'Marcus Aurelius Antoninus Augustus'),
      );

      expect(find.text('Marcus Aurelius Antoninus Augustus'), findsOneWidget);
    });

    testWidgets('should render with short author name', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(author: 'Zeno'));

      expect(find.text('Zeno'), findsOneWidget);
    });

    testWidgets('should have minimum size from mainAxisSize.min', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final row = tester.widget<Row>(find.byType(Row).first);
      expect(row.mainAxisSize, MainAxisSize.min);
    });
  });
}
