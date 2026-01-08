import 'package:home_widget/home_widget.dart';
import '../../../../core/constants/widget_constants.dart';

/// Service for managing widget lifecycle and interactions
class WidgetService {
  /// Initialize widget callbacks
  Future<void> initialize() async {
    await HomeWidget.setAppGroupId(WidgetConstants.appGroupId);

    // Listen for widget interactions
    HomeWidget.widgetClicked.listen(_handleWidgetClick);
  }

  void _handleWidgetClick(Uri? uri) {
    if (uri == null) return;

    // Handle different widget actions based on URI
    // Example: stoicmind://quote/detail
    switch (uri.path) {
      case '/detail':
        // Navigate to quote detail
        break;
      case '/share':
        // Open share sheet
        break;
      default:
        // Open home screen
        break;
    }
  }

  /// Force refresh all widgets
  Future<void> refreshWidgets() async {
    await HomeWidget.updateWidget(
      iOSName: WidgetConstants.iOSWidgetName,
      qualifiedAndroidName: WidgetConstants.androidWidgetName,
    );
  }
}
