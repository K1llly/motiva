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
  Future<void> syncShuffledOrder(List<int> shuffledOrder);
  Future<void> syncStartDate(DateTime startDate);
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

  @override
  Future<void> syncShuffledOrder(List<int> shuffledOrder) async {
    try {
      await HomeWidget.setAppGroupId(WidgetConstants.appGroupId);
      // Convert to 0-indexed for Swift (Flutter uses 1-30, Swift needs 0-29)
      // Serialize as comma-separated string since home_widget only supports primitives
      final zeroIndexedOrder = shuffledOrder.map((i) => i - 1).toList();
      final serialized = zeroIndexedOrder.join(',');
      await HomeWidget.saveWidgetData<String>(
        WidgetConstants.shuffledOrderKey,
        serialized,
      );
    } catch (e) {
      throw WidgetException('Failed to sync shuffled order: $e');
    }
  }

  @override
  Future<void> syncStartDate(DateTime startDate) async {
    try {
      await HomeWidget.setAppGroupId(WidgetConstants.appGroupId);
      // Store as Unix timestamp (seconds since epoch)
      await HomeWidget.saveWidgetData<double>(
        WidgetConstants.startDateKey,
        startDate.millisecondsSinceEpoch / 1000.0,
      );
    } catch (e) {
      throw WidgetException('Failed to sync start date: $e');
    }
  }
}
