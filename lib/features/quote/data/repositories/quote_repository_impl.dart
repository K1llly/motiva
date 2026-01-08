import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/quote.dart';
import '../../domain/repositories/quote_repository.dart';
import '../datasources/quote_local_datasource.dart';

/// Repository implementation - bridges data sources to domain
/// Converts Exceptions to Failures (data errors -> domain errors)
class QuoteRepositoryImpl implements QuoteRepository {
  final QuoteLocalDataSource localDataSource;

  QuoteRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, Quote>> getDailyQuote(int dayNumber) async {
    try {
      final quote = await localDataSource.getQuoteForDay(dayNumber);
      return Right(quote);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Quote>> getQuoteById(String id) async {
    try {
      final quote = await localDataSource.getQuoteById(id);
      return Right(quote);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Quote>>> getAllQuotes() async {
    try {
      final quotes = await localDataSource.getAllQuotes();
      return Right(quotes);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markQuoteAsRead(String quoteId) async {
    try {
      await localDataSource.markQuoteAsDisplayed(quoteId, DateTime.now());
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> hasReadTodaysQuote() async {
    try {
      // This would need additional logic to track today's read status
      return const Right(false);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
