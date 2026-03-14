import 'package:equatable/equatable.dart';

/// Widget appearance settings entity
class WidgetSettings extends Equatable {
  final int backgroundColor;
  final int textColor;
  final bool isGlassModeEnabled;
  final String fontKey;

  const WidgetSettings({
    required this.backgroundColor,
    required this.textColor,
    required this.isGlassModeEnabled,
    this.fontKey = 'classic',
  });

  /// Default settings
  static const WidgetSettings defaultSettings = WidgetSettings(
    backgroundColor: 0xFF1A1A1A,
    textColor: 0xFFFFFFFF,
    isGlassModeEnabled: false,
    fontKey: 'classic',
  );

  /// Get effective background color (null if glass mode is enabled)
  int? get effectiveBackgroundColor =>
      isGlassModeEnabled ? null : backgroundColor;

  /// Create copy with modifications
  WidgetSettings copyWith({
    int? backgroundColor,
    int? textColor,
    bool? isGlassModeEnabled,
    String? fontKey,
  }) {
    return WidgetSettings(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      isGlassModeEnabled: isGlassModeEnabled ?? this.isGlassModeEnabled,
      fontKey: fontKey ?? this.fontKey,
    );
  }

  @override
  List<Object?> get props => [backgroundColor, textColor, isGlassModeEnabled, fontKey];
}
