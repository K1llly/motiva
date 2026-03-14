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
      final results = await Future.wait<Object?>([
        HomeWidget.getWidgetData<int>(WidgetConstants.backgroundColorKey),
        HomeWidget.getWidgetData<int>(WidgetConstants.textColorKey),
        HomeWidget.getWidgetData<bool>(WidgetConstants.glassModeKey),
        HomeWidget.getWidgetData<String>(WidgetConstants.widgetFontKey),
      ], eagerError: false);

      final backgroundColor = results[0] as int?;
      final textColor = results[1] as int?;
      final glassMode = results[2] as bool?;
      final fontKey = results[3] as String?;

      return WidgetSettings(
        backgroundColor:
            backgroundColor ?? WidgetSettings.defaultSettings.backgroundColor,
        textColor:
            textColor ?? WidgetSettings.defaultSettings.textColor,
        isGlassModeEnabled:
            glassMode ?? WidgetSettings.defaultSettings.isGlassModeEnabled,
        fontKey: fontKey ?? WidgetSettings.defaultSettings.fontKey,
      );
    } catch (e) {
      throw WidgetException('Failed to load widget settings: $e');
    }
  }

  @override
  Future<void> saveSettings(WidgetSettings settings) async {
    try {
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
        HomeWidget.saveWidgetData<String>(
          WidgetConstants.widgetFontKey,
          settings.fontKey,
        ),
      ]);
    } catch (e) {
      throw WidgetException('Failed to save widget settings: $e');
    }
  }
}
