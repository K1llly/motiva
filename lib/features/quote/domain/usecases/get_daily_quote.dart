import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/quote.dart';
import '../repositories/quote_repository.dart';

/// Use case: Get today's daily quote
/// Depends on abstraction (QuoteRepository), not implementation
class GetDailyQuote implements UseCase<Quote, GetDailyQuoteParams> {
  final QuoteRepository repository;

  GetDailyQuote(this.repository);

  @override
  Future<Either<Failure, Quote>> call(GetDailyQuoteParams params) async {
    return await repository.getDailyQuote(params.dayNumber);
  }
}

class GetDailyQuoteParams {
  final int dayNumber;

  const GetDailyQuoteParams({required this.dayNumber});
}
