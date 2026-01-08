import '../models/quote_model.dart';

/// Data source interface - defines data operations
/// Throws exceptions (converted to Failures in repository)
abstract class QuoteLocalDataSource {
  /// Get quote for a specific day using user's shuffled order
  /// Throws [CacheException] if not found
  Future<QuoteModel> getQuoteForDay(int dayNumber);

  /// Get quote by ID
  Future<QuoteModel> getQuoteById(String id);

  /// Get all quotes from database
  Future<List<QuoteModel>> getAllQuotes();

  /// Update quote's displayed timestamp
  Future<void> markQuoteAsDisplayed(String quoteId, DateTime displayedAt);

  /// Initialize database with quotes
  Future<void> initializeQuotes(List<QuoteModel> quotes);

  /// Check if quotes are loaded
  Future<bool> hasQuotes();
}
