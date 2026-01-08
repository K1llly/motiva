import 'package:home_widget/home_widget.dart';
import '../../../../core/constants/widget_constants.dart';
import '../../../../core/errors/exceptions.dart';

abstract class WidgetDataSource {
  Future<void> saveWidgetData({
    required String quoteText,
    required String author,
    required int dayNumber,
  });
  Future<void> updateWidget();
  Future<DateTime?> getLastUpdateTime();
}

class WidgetDataSourceImpl implements WidgetDataSource {
  @override
  Future<void> saveWidgetData({
    required String quoteText,
    required String author,
    required int dayNumber,
  }) async {
    try {
      // Set app group for iOS
      await HomeWidget.setAppGroupId(WidgetConstants.appGroupId);

      // Save data to shared storage
      await Future.wait([
        HomeWidget.saveWidgetData<String>(
          WidgetConstants.quoteTextKey,
          quoteText,
        ),
        HomeWidget.saveWidgetData<String>(
          WidgetConstants.authorKey,
          author,
        ),
        HomeWidget.saveWidgetData<int>(
          WidgetConstants.dayNumberKey,
          dayNumber,
        ),
        HomeWidget.saveWidgetData<String>(
          WidgetConstants.lastUpdatedKey,
          DateTime.now().toIso8601String(),
        ),
      ]);
    } catch (e) {
      throw WidgetException('Failed to save widget data: $e');
    }
  }

  @override
  Future<void> updateWidget() async {
    try {
      await HomeWidget.updateWidget(
        iOSName: WidgetConstants.iOSWidgetName,
        qualifiedAndroidName: WidgetConstants.androidWidgetName,
      );
    } catch (e) {
      throw WidgetException('Failed to update widget: $e');
    }
  }

  @override
  Future<DateTime?> getLastUpdateTime() async {
    try {
      final lastUpdated = await HomeWidget.getWidgetData<String>(
        WidgetConstants.lastUpdatedKey,
      );
      if (lastUpdated != null) {
        return DateTime.parse(lastUpdated);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
