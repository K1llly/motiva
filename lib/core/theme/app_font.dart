import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppFont {
  classic,
  modern,
  rounded,
  elegantSerif,
  monospace;

  String get displayName {
    return switch (this) {
      AppFont.classic => 'Classic',
      AppFont.modern => 'Modern',
      AppFont.rounded => 'Rounded',
      AppFont.elegantSerif => 'Elegant Serif',
      AppFont.monospace => 'Monospace',
    };
  }

  /// The primary/quote font style
  TextStyle get primaryStyle {
    return switch (this) {
      AppFont.classic => GoogleFonts.playfairDisplay(),
      AppFont.modern => GoogleFonts.lato(),
      AppFont.rounded => GoogleFonts.nunito(fontWeight: FontWeight.w500),
      AppFont.elegantSerif => GoogleFonts.lora(),
      AppFont.monospace => GoogleFonts.jetBrainsMono(),
    };
  }

  /// The body/secondary font style
  TextStyle get bodyStyle {
    return switch (this) {
      AppFont.classic => GoogleFonts.lato(),
      AppFont.modern => GoogleFonts.lato(),
      AppFont.rounded => GoogleFonts.nunito(fontWeight: FontWeight.w500),
      AppFont.elegantSerif => GoogleFonts.lora(),
      AppFont.monospace => GoogleFonts.jetBrainsMono(),
    };
  }

  /// Key string for persistence
  String get key => name;

  /// iOS widget font design key
  String get widgetDesignKey {
    return switch (this) {
      AppFont.classic => 'serif',
      AppFont.modern => 'default',
      AppFont.rounded => 'rounded',
      AppFont.elegantSerif => 'serif',
      AppFont.monospace => 'monospaced',
    };
  }

  static AppFont fromKey(String? key) {
    if (key == null) return AppFont.classic;
    return AppFont.values.where((f) => f.key == key).firstOrNull ??
        AppFont.classic;
  }
}
