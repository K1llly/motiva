import 'package:flutter/material.dart';
import 'app.dart';
import 'di/injection_container.dart' as di;
import 'core/data/quotes_data.dart';
import 'features/quote/data/datasources/quote_local_datasource.dart';
import 'features/quote/data/models/quote_model.dart';
import 'features/home_widget/domain/usecases/update_widget_data.dart';
import 'features/quote/domain/usecases/get_daily_quote.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await di.init();

  // Initialize quotes if first launch
  await _initializeQuotes();

  // Initialize widget with current quote
  await _initializeWidget();

  runApp(const MotivaApp());
}

Future<void> _initializeQuotes() async {
  final quoteDataSource = di.sl<QuoteLocalDataSource>();
  final hasQuotes = await quoteDataSource.hasQuotes();

  if (!hasQuotes) {
    final quotes = stoicQuotes.map((q) => QuoteModel.fromJson(q)).toList();
    await quoteDataSource.initializeQuotes(quotes);
  }
}

/// Initialize widget with current daily quote data
/// This ensures the widget shows content even before the app is fully opened
Future<void> _initializeWidget() async {
  try {
    final dateUtilsService = di.sl<di.DateUtilsService>();
    final getDailyQuote = di.sl<GetDailyQuote>();
    final updateWidgetData = di.sl<UpdateWidgetData>();

    final dayNumber = dateUtilsService.getCurrentDayNumber();
    final quoteResult = await getDailyQuote(GetDailyQuoteParams(dayNumber: dayNumber));

    await quoteResult.fold(
      (failure) async {
        // If we fail to get the quote, don't crash - widget will show default
        debugPrint('Failed to initialize widget: ${failure.message}');
      },
      (quote) async {
        await updateWidgetData(UpdateWidgetParams(
          quoteText: quote.text,
          author: quote.author,
          dayNumber: dayNumber,
        ));
      },
    );
  } catch (e) {
    // Widget initialization is not critical - app should still run
    debugPrint('Widget initialization error: $e');
  }
}
