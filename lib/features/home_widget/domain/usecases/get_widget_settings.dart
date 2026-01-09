import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/widget_settings.dart';
import '../repositories/widget_settings_repository.dart';

class GetWidgetSettings implements UseCase<WidgetSettings, NoParams> {
  final WidgetSettingsRepository repository;

  GetWidgetSettings(this.repository);

  @override
  Future<Either<Failure, WidgetSettings>> call(NoParams params) async {
    return await repository.getWidgetSettings();
  }
}
