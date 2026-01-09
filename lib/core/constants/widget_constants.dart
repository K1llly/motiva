/// Constants for home screen widget configuration
class WidgetConstants {
  WidgetConstants._();

  /// App group identifier for iOS data sharing
  static const String appGroupId = 'group.com.motiva.stoicmind';

  /// Widget data keys
  static const String quoteTextKey = 'quote_text';
  static const String authorKey = 'quote_author';
  static const String dayNumberKey = 'day_number';
  static const String lastUpdatedKey = 'last_updated';

  /// Widget identifiers
  static const String iOSWidgetName = 'MotivaWidget';
  static const String androidWidgetName = 'com.motiva.stoic_mind.widget.MotivaWidgetReceiver';

  /// Widget appearance keys
  static const String backgroundColorKey = 'widget_background_color';
  static const String textColorKey = 'widget_text_color';
  static const String glassModeKey = 'widget_glass_mode';
}
