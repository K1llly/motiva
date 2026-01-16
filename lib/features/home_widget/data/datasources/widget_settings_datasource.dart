import 'package:home_widget/home_widget.dart';
import '../../../../core/constants/widget_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/widget_settings.dart';

abstract class WidgetSettingsDataSource {
  Future<WidgetSettings> getSettings();
  Future<void> saveSettings(WidgetSettings settings);
}

class WidgetSettingsDataSourceImpl implements WidgetSettingsDataSource {
  @override
  Future<WidgetSettings> getSettings() async {
    try {
      await HomeWidget.setAppGroupId(WidgetConstants.appGroupId);

      // Fetch settings sequentially to avoid Future.wait failure propagation
      final backgroundColor = await HomeWidget.getWidgetData<int>(
          WidgetConstants.backgroundColorKey);
      final textColor = await HomeWidget.getWidgetData<int>(
          WidgetConstants.textColorKey);
      final glassMode = await HomeWidget.getWidgetData<bool>(
          WidgetConstants.glassModeKey);

      return WidgetSettings(
        backgroundColor:
            backgroundColor ?? WidgetSettings.defaultSettings.backgroundColor,
        textColor:
            textColor ?? WidgetSettings.defaultSettings.textColor,
        isGlassModeEnabled:
            glassMode ?? WidgetSettings.defaultSettings.isGlassModeEnabled,
      );
    } catch (e) {
      throw WidgetException('Failed to load widget settings: $e');
    }
  }

  @override
  Future<void> saveSettings(WidgetSettings settings) async {
    try {
      await HomeWidget.setAppGroupId(WidgetConstants.appGroupId);

      await Future.wait([
        HomeWidget.saveWidgetData<int>(
          WidgetConstants.backgroundColorKey,
          settings.backgroundColor,
        ),
        HomeWidget.saveWidgetData<int>(
          WidgetConstants.textColorKey,
          settings.textColor,
        ),
        HomeWidget.saveWidgetData<bool>(
          WidgetConstants.glassModeKey,
          settings.isGlassModeEnabled,
        ),
      ]);
    } catch (e) {
      throw WidgetException('Failed to save widget settings: $e');
    }
  }
}
