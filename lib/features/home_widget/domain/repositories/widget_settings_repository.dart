import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/widget_settings.dart';

abstract class WidgetSettingsRepository {
  /// Get current widget appearance settings
  Future<Either<Failure, WidgetSettings>> getWidgetSettings();

  /// Save widget appearance settings
  Future<Either<Failure, void>> saveWidgetSettings(WidgetSettings settings);
}
