import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/widget_repository.dart';

class SyncWidgetQuote implements UseCase<void, NoParams> {
  final WidgetRepository repository;

  SyncWidgetQuote(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.registerWidgetCallback();
  }
}
