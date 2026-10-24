import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zeokash/core/theme/paisaji_brand.dart';

class AppTheme {
  AppTheme._();

  // Core Colors (PaisaJi Brand Guidelines v3.0)
  static const Color primaryBlue = PaisaJiColors.primary;
  static const Color primaryNavy = PaisaJiColors.navy;
  static const Color aiTeal = Color(0xFF14B8A6);
  static const Color background = PaisaJiColors.background;
  static const Color surface = PaisaJiColors.surface;
  static const Color primaryText = PaisaJiColors.textPrimary;
  static const Color secondaryText = PaisaJiColors.textSecondary;
  static const Color border = PaisaJiColors.border;
  
  // Semantic Colors
  static const Color success = PaisaJiColors.success;
  static const Color warning = PaisaJiColors.warning;
  static const Color error = PaisaJiColors.error;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        onPrimary: Colors.white,
        secondary: aiTeal,
        onSecondary: Colors.white,
        error: error,
        onError: Colors.white,
        surface: surface,
        onSurface: primaryText,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: primaryText,
        elevation: 0,
        centerTitle: false,
      ),
      textTheme: _textTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      cardTheme: _cardTheme,
      bottomSheetTheme: _bottomSheetTheme,
    );
  }

  static TextTheme get _textTheme {
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: primaryText, fontFeatures: [FontFeature.tabularFigures()]),
      displayMedium: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: primaryText),
      displaySmall: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: primaryText),
      headlineMedium: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: primaryText),
      bodyLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: primaryText),
      bodyMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: secondaryText),
      labelLarge: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: primaryText),
      bodySmall: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: secondaryText),
    );
  }

  static ElevatedButtonThemeData get _elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(0, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  static InputDecorationTheme get _inputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error),
      ),
      hintStyle: const TextStyle(color: secondaryText, fontSize: 16),
    );
  }

  static CardThemeData get _cardTheme {
    return CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: border),
      ),
      margin: EdgeInsets.zero,
    );
  }

  static BottomSheetThemeData get _bottomSheetTheme {
    return const BottomSheetThemeData(
      backgroundColor: surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }
}
