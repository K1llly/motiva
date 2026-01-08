import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/quote.dart';

/// Repository contract - defines WHAT we need, not HOW we get it
/// Uses Either for functional error handling
abstract class QuoteRepository {
  /// Get today's quote based on day number since installation
  Future<Either<Failure, Quote>> getDailyQuote(int dayNumber);

  /// Get quote by specific ID
  Future<Either<Failure, Quote>> getQuoteById(String id);

  /// Get all quotes (for debugging/admin)
  Future<Either<Failure, List<Quote>>> getAllQuotes();

  /// Mark quote as read for today
  Future<Either<Failure, void>> markQuoteAsRead(String quoteId);

  /// Check if today's quote has been read
  Future<Either<Failure, bool>> hasReadTodaysQuote();
}
