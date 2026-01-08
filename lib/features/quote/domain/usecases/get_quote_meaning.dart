import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/quote.dart';
import '../repositories/quote_repository.dart';

/// Use case: Get a specific quote's meaning by ID
class GetQuoteMeaning implements UseCase<Quote, GetQuoteMeaningParams> {
  final QuoteRepository repository;

  GetQuoteMeaning(this.repository);

  @override
  Future<Either<Failure, Quote>> call(GetQuoteMeaningParams params) async {
    return await repository.getQuoteById(params.quoteId);
  }
}

class GetQuoteMeaningParams {
  final String quoteId;

  const GetQuoteMeaningParams({required this.quoteId});
}
