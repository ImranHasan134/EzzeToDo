import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════════
// COLORS
// ════════════════════════════════════════════════════════════

class AppColors {
  static const primary = Color(0xFF534AB7);
  static const primaryLight = Color(0xFF7F77DD);
  static const primarySurface = Color(0xFFEEEDFE);
  static const high = Color(0xFFE24B4A);
  static const highBg = Color(0xFFFCEBEB);
  static const medium = Color(0xFFBA7517);
  static const mediumBg = Color(0xFFFAEEDA);
  static const low = Color(0xFF3B6D11);
  static const lowBg = Color(0xFFEAF3DE);
  static const todo = Color(0xFF378ADD);
  static const todoBg = Color(0xFFE6F1FB);
  static const inProgress = Color(0xFFBA7517);
  static const inProgressBg = Color(0xFFFAEEDA);
  static const completed = Color(0xFF3B6D11);
  static const completedBg = Color(0xFFEAF3DE);
  static const error = Color(0xFFE24B4A);
  static const bgLight = Color(0xFFF7F6F2);
  static const cardLight = Color(0xFFFFFFFF);
  static const borderLight = Color(0xFFEAEAE4);
  static const textLight = Color(0xFF1A1A22);
  static const mutedLight = Color(0xFF767670);
  static const inputBgLight = Color(0xFFF4F3EF);
  static const inputBorderLight = Color(0xFFDDDDD6);
  static const bgDark = Color(0xFF16161A);
  static const cardDark = Color(0xFF1E1E24);
  static const borderDark = Color(0xFF2E2E38);
  static const textDark = Color(0xFFF0EFE8);
  static const mutedDark = Color(0xFF888880);
  static const inputBgDark = Color(0xFF26262E);
  static const inputBorderDark = Color(0xFF3A3A46);
}

// ════════════════════════════════════════════════════════════
// THEME
// ════════════════════════════════════════════════════════════

class AppTheme {
  static TextTheme _tt(Color text, Color muted) => TextTheme(
        displaySmall:
            TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: text),
        headlineMedium:
            TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: text),
        headlineSmall:
            TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: text),
        titleLarge:
            TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: text),
        titleMedium:
            TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: text),
        bodyLarge: TextStyle(fontSize: 15, color: text, height: 1.6),
        bodyMedium: TextStyle(fontSize: 14, color: text, height: 1.5),
        bodySmall: TextStyle(fontSize: 12, color: muted),
        labelLarge:
            TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: text),
      );

  static ThemeData light() => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.primaryLight,
          surface: AppColors.cardLight,
          background: AppColors.bgLight,
          error: AppColors.error,
          onPrimary: Colors.white,
          onSurface: AppColors.textLight,
        ),
        scaffoldBackgroundColor: AppColors.bgLight,
        textTheme: _tt(AppColors.textLight, AppColors.mutedLight),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.cardLight,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textLight),
          iconTheme: const IconThemeData(color: AppColors.textLight),
        ),
        cardTheme: CardThemeData(
          color: AppColors.cardLight,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(
                  color: AppColors.borderLight, width: 1.5)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.inputBgLight,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: AppColors.inputBorderLight, width: 1.5)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: AppColors.inputBorderLight, width: 1.5)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          labelStyle: TextStyle(color: AppColors.mutedLight, fontSize: 14),
          hintStyle: TextStyle(color: AppColors.mutedLight, fontSize: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          textStyle:
              TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        )),
        outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side:
              const BorderSide(color: AppColors.borderLight, width: 1.5),
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          textStyle:
              TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        )),
        dividerTheme: const DividerThemeData(
            color: AppColors.borderLight, thickness: 1, space: 1),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 4,
            shape: CircleBorder()),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected)
                  ? AppColors.primary
                  : Colors.white),
          trackColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected)
                  ? AppColors.primaryLight
                  : AppColors.borderLight),
        ),
      );

  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryLight,
          secondary: AppColors.primary,
          surface: AppColors.cardDark,
          background: AppColors.bgDark,
          error: AppColors.error,
          onPrimary: Colors.white,
          onSurface: AppColors.textDark,
        ),
        scaffoldBackgroundColor: AppColors.bgDark,
        textTheme: _tt(AppColors.textDark, AppColors.mutedDark),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.cardDark,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark),
          iconTheme: const IconThemeData(color: AppColors.textDark),
        ),
        cardTheme: CardThemeData(
          color: AppColors.cardDark,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(
                  color: AppColors.borderDark, width: 1.5)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.inputBgDark,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: AppColors.inputBorderDark, width: 1.5)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: AppColors.inputBorderDark, width: 1.5)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: AppColors.primaryLight, width: 1.5)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          labelStyle: TextStyle(color: AppColors.mutedDark, fontSize: 14),
          hintStyle: TextStyle(color: AppColors.mutedDark, fontSize: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          elevation: 0,
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          textStyle:
              TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        )),
        outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          side:
              const BorderSide(color: AppColors.borderDark, width: 1.5),
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          textStyle:
              TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        )),
        dividerTheme: const DividerThemeData(
            color: AppColors.borderDark, thickness: 1, space: 1),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: AppColors.primaryLight,
            foregroundColor: Colors.white,
            elevation: 4,
            shape: CircleBorder()),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected)
                  ? AppColors.primaryLight
                  : Colors.white),
          trackColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected)
                  ? AppColors.primary
                  : AppColors.borderDark),
        ),
      );
}
