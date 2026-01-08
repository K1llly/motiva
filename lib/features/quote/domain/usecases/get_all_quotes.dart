import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/quote.dart';
import '../repositories/quote_repository.dart';

/// Use case: Get all quotes from the database
class GetAllQuotes implements UseCase<List<Quote>, NoParams> {
  final QuoteRepository repository;

  GetAllQuotes(this.repository);

  @override
  Future<Either<Failure, List<Quote>>> call(NoParams params) async {
    return await repository.getAllQuotes();
  }
}
