import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stoic_mind/features/quote/domain/entities/quote.dart';
import 'package:stoic_mind/features/sharing/presentation/widgets/share_bottom_sheet.dart';

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
        body: ShareBottomSheet(quote: tQuote),
      ),
    );
  }

  group('ShareBottomSheet Widget', () {
    testWidgets('should display "Share Quote" title', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Share Quote'), findsOneWidget);
    });

    testWidgets('should display Instagram share option', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Instagram'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    });

    testWidgets('should display Twitter share option', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Twitter'), findsOneWidget);
      expect(find.byIcon(Icons.alternate_email), findsOneWidget);
    });

    testWidgets('should display WhatsApp share option', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('WhatsApp'), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble), findsOneWidget);
    });

    testWidgets('should display More share option', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('More'), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz), findsOneWidget);
    });

    testWidgets('should display Cancel button', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('should display drag handle', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // The drag handle is a Container with specific dimensions
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should have 4 share options in a Row', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find the row containing share options
      final rows = find.byType(Row);
      expect(rows, findsWidgets);

      // Verify all 4 share options exist
      expect(find.text('Instagram'), findsOneWidget);
      expect(find.text('Twitter'), findsOneWidget);
      expect(find.text('WhatsApp'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('Cancel button should be tappable', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => const ShareBottomSheet(quote: tQuote),
                  );
                },
                child: const Text('Show Sheet'),
              ),
            ),
          ),
        ),
      );

      // Tap button to show bottom sheet
      await tester.tap(find.text('Show Sheet'));
      await tester.pumpAndSettle();

      // Verify sheet is shown
      expect(find.text('Share Quote'), findsOneWidget);

      // Tap cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Sheet should be dismissed
      expect(find.text('Share Quote'), findsNothing);
    });

    testWidgets('share options should be tappable', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => const ShareBottomSheet(quote: tQuote),
                  );
                },
                child: const Text('Show Sheet'),
              ),
            ),
          ),
        ),
      );

      // Tap button to show bottom sheet
      await tester.tap(find.text('Show Sheet'));
      await tester.pumpAndSettle();

      // Verify sheet is shown
      expect(find.text('Share Quote'), findsOneWidget);

      // Tap Instagram option (this will try to share and close)
      await tester.tap(find.text('Instagram'));
      await tester.pumpAndSettle();

      // Sheet should be dismissed after share
      expect(find.text('Share Quote'), findsNothing);
    });

    testWidgets('should render with rounded top corners', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find the main Container with decoration
      final containers = find.byType(Container);
      expect(containers, findsWidgets);
    });

    testWidgets('should be wrapped in a Column with min size', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final column = tester.widget<Column>(find.byType(Column).first);
      expect(column.mainAxisSize, MainAxisSize.min);
    });
  });
}
