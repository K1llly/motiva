import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/widget_repository.dart';

class UpdateWidgetData implements UseCase<void, UpdateWidgetParams> {
  final WidgetRepository repository;

  UpdateWidgetData(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateWidgetParams params) async {
    return await repository.updateWidgetData(
      quoteText: params.quoteText,
      author: params.author,
      dayNumber: params.dayNumber,
    );
  }
}

class UpdateWidgetParams {
  final String quoteText;
  final String author;
  final int dayNumber;

  const UpdateWidgetParams({
    required this.quoteText,
    required this.author,
    required this.dayNumber,
  });
}
