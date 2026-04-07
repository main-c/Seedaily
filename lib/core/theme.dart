import 'package:flutter/material.dart';

class AppTheme {
  static const String appVersion = '1.0.0';

  static const Color seedGold = Color(0xFFEF9D10);
  static const Color deepNavy = Color(0xFF3B4D61);
  static const Color mistGreyBlue = Color(0xFF6B7B8C);
  static const Color backgroundLight = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color borderSubtle = Color(0xFFE0E4EA);
  static const Color textPrimary = Color(0xFF1E242C);
  static const Color textMuted = Color(0xFF7A8699);
  static const Color success = Color(0xFF3BAE6E);
  static const Color warning = Color(0xFFF4B449);
  static const Color error = Color(0xFFE45B5B);
  static const Color info = Color(0xFF3D7DD8);

  static const String _fontFamily = 'Lexend';

  static TextStyle _lexend({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) =>
      TextStyle(
        fontFamily: _fontFamily,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );

  static ThemeData get lightTheme {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: seedGold,
        onPrimary: surface,
        secondary: deepNavy,
        onSecondary: surface,
        tertiary: mistGreyBlue,
        surface: surface,
        onSurface: textPrimary,
        error: error,
        onError: surface,
        surfaceContainerLowest: backgroundLight,
        outline: borderSubtle,
      ),
      scaffoldBackgroundColor: backgroundLight,
      cardColor: surface,
    );

    return baseTheme.copyWith(
      textTheme: _buildTextTheme(baseTheme.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: deepNavy,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: _lexend(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: deepNavy,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderSubtle, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: seedGold,
          foregroundColor: surface,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: _lexend(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: deepNavy,
          side: const BorderSide(color: borderSubtle, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: _lexend(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: seedGold,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: _lexend(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: backgroundLight,
        deleteIconColor: textMuted,
        labelStyle: _lexend(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: deepNavy,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: borderSubtle),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: seedGold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        labelStyle: _lexend(fontSize: 15, color: textMuted),
        hintStyle: _lexend(fontSize: 15, color: textMuted),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: seedGold,
        foregroundColor: surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderSubtle,
        thickness: 1,
        space: 1,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return seedGold;
          }
          return surface;
        }),
        checkColor: WidgetStateProperty.all(surface),
        side: const BorderSide(color: borderSubtle, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return surface;
          }
          return textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return seedGold;
          }
          return borderSubtle;
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: seedGold,
        linearTrackColor: borderSubtle,
      ),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge:
          _lexend(fontSize: 57, fontWeight: FontWeight.w400, color: textPrimary),
      displayMedium:
          _lexend(fontSize: 45, fontWeight: FontWeight.w400, color: textPrimary),
      displaySmall:
          _lexend(fontSize: 36, fontWeight: FontWeight.w400, color: textPrimary),
      headlineLarge:
          _lexend(fontSize: 32, fontWeight: FontWeight.w600, color: deepNavy),
      headlineMedium:
          _lexend(fontSize: 28, fontWeight: FontWeight.w600, color: deepNavy),
      headlineSmall:
          _lexend(fontSize: 24, fontWeight: FontWeight.w600, color: deepNavy),
      titleLarge:
          _lexend(fontSize: 22, fontWeight: FontWeight.w600, color: deepNavy),
      titleMedium:
          _lexend(fontSize: 16, fontWeight: FontWeight.w600, color: deepNavy),
      titleSmall:
          _lexend(fontSize: 14, fontWeight: FontWeight.w600, color: deepNavy),
      bodyLarge:
          _lexend(fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary),
      bodyMedium:
          _lexend(fontSize: 14, fontWeight: FontWeight.w400, color: textPrimary),
      bodySmall:
          _lexend(fontSize: 12, fontWeight: FontWeight.w400, color: textMuted),
      labelLarge:
          _lexend(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary),
      labelMedium:
          _lexend(fontSize: 12, fontWeight: FontWeight.w500, color: textMuted),
      labelSmall:
          _lexend(fontSize: 11, fontWeight: FontWeight.w500, color: textMuted),
    );
  }

  static ThemeData get darkTheme {
    const darkBackground = Color(0xFF0E141B);
    const darkSurface = Color(0xFF18212C);
    const darkSurfaceElevated = Color(0xFF1F2C3A);
    const darkTextPrimary = Color(0xFFF7F8FA);
    const darkTextMuted = Color(0xFF8A9BB0);
    const darkBorder = Color(0xFF2A3547);

    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: seedGold,
        onPrimary: darkBackground,
        secondary: mistGreyBlue,
        onSecondary: darkTextPrimary,
        tertiary: mistGreyBlue,
        surface: darkSurface,
        onSurface: darkTextPrimary,
        error: error,
        onError: darkBackground,
        surfaceContainerLowest: darkBackground,
        outline: darkBorder,
      ),
      scaffoldBackgroundColor: darkBackground,
      cardColor: darkSurface,
    );

    return baseTheme.copyWith(
      textTheme: _buildTextTheme(baseTheme.textTheme).apply(
        bodyColor: darkTextPrimary,
        displayColor: darkTextPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: _lexend(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: seedGold,
          foregroundColor: darkBackground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: _lexend(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkTextPrimary,
          side: const BorderSide(color: darkBorder, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: _lexend(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: seedGold,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: _lexend(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkSurfaceElevated,
        deleteIconColor: darkTextMuted,
        labelStyle: _lexend(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: darkTextPrimary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: darkBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: seedGold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        labelStyle: _lexend(fontSize: 15, color: darkTextMuted),
        hintStyle: _lexend(fontSize: 15, color: darkTextMuted),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: seedGold,
        foregroundColor: darkBackground,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 1,
        space: 1,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return seedGold;
          return darkSurfaceElevated;
        }),
        checkColor: WidgetStateProperty.all(darkBackground),
        side: const BorderSide(color: darkBorder, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return darkBackground;
          return darkTextMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return seedGold;
          return darkBorder;
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: seedGold,
        linearTrackColor: darkBorder,
      ),
    );
  }
}
