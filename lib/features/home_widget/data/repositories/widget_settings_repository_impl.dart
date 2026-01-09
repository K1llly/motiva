import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/widget_settings.dart';
import '../../domain/repositories/widget_settings_repository.dart';
import '../datasources/widget_settings_datasource.dart';

class WidgetSettingsRepositoryImpl implements WidgetSettingsRepository {
  final WidgetSettingsDataSource dataSource;

  WidgetSettingsRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, WidgetSettings>> getWidgetSettings() async {
    try {
      final settings = await dataSource.getSettings();
      return Right(settings);
    } on WidgetException catch (e) {
      return Left(WidgetFailure(e.message));
    } catch (e) {
      // Return default settings on error
      return const Right(WidgetSettings.defaultSettings);
    }
  }

  @override
  Future<Either<Failure, void>> saveWidgetSettings(
      WidgetSettings settings) async {
    try {
      await dataSource.saveSettings(settings);
      return const Right(null);
    } on WidgetException catch (e) {
      return Left(WidgetFailure(e.message));
    } catch (e) {
      return Left(WidgetFailure('Failed to save settings: ${e.toString()}'));
    }
  }
}
