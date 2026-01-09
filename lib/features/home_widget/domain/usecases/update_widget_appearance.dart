import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/widget_settings.dart';
import '../repositories/widget_repository.dart';
import '../repositories/widget_settings_repository.dart';

class UpdateWidgetAppearance
    implements UseCase<void, UpdateWidgetAppearanceParams> {
  final WidgetSettingsRepository settingsRepository;
  final WidgetRepository widgetRepository;

  UpdateWidgetAppearance({
    required this.settingsRepository,
    required this.widgetRepository,
  });

  @override
  Future<Either<Failure, void>> call(UpdateWidgetAppearanceParams params) async {
    // Save settings
    final saveResult =
        await settingsRepository.saveWidgetSettings(params.settings);

    return saveResult.fold(
      (failure) => Left(failure),
      (_) async {
        // Trigger widget refresh
        return await widgetRepository.refreshWidget();
      },
    );
  }
}

class UpdateWidgetAppearanceParams extends Equatable {
  final WidgetSettings settings;

  const UpdateWidgetAppearanceParams({required this.settings});

  @override
  List<Object?> get props => [settings];
}
