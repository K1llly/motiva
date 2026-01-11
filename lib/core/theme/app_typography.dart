import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Text styles for the app
class AppTypography {
  AppTypography._();

  // Cached TextTheme - created once, reused forever
  static final TextTheme _textTheme = TextTheme(
    displayLarge: GoogleFonts.playfairDisplay(
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
    displayMedium: GoogleFonts.playfairDisplay(
      fontSize: 28,
      fontWeight: FontWeight.bold,
    ),
    displaySmall: GoogleFonts.playfairDisplay(
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    headlineLarge: GoogleFonts.lato(
      fontSize: 22,
      fontWeight: FontWeight.w600,
    ),
    headlineMedium: GoogleFonts.lato(
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: GoogleFonts.lato(
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: GoogleFonts.lato(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    titleMedium: GoogleFonts.lato(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: GoogleFonts.lato(
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: GoogleFonts.lato(
      fontSize: 16,
      fontWeight: FontWeight.normal,
    ),
    bodyMedium: GoogleFonts.lato(
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),
    bodySmall: GoogleFonts.lato(
      fontSize: 12,
      fontWeight: FontWeight.normal,
    ),
    labelLarge: GoogleFonts.lato(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    labelMedium: GoogleFonts.lato(
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: GoogleFonts.lato(
      fontSize: 10,
      fontWeight: FontWeight.w500,
    ),
  );

  static TextTheme get textTheme => _textTheme;

  // Cached quote style
  static final TextStyle _quoteStyle = GoogleFonts.playfairDisplay(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.italic,
    height: 1.5,
  );

  // Cached author style
  static final TextStyle _authorStyle = GoogleFonts.lato(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 1.2,
  );

  /// Quote text style - larger, more elegant
  static TextStyle quoteStyle(BuildContext context) => _quoteStyle;

  /// Author text style
  static TextStyle authorStyle(BuildContext context) => _authorStyle;
}
