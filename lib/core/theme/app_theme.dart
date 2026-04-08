import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Tema global do GuIA baseado em [AppColors].
class AppTheme {
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.indigo,
        primary: AppColors.indigo,
        secondary: AppColors.sand,
        surface: AppColors.surface,
        error: AppColors.error,
        brightness: Brightness.light,
      ).copyWith(
        onPrimary: Colors.white,
        onSecondary: AppColors.slate,
        onSurface: AppColors.slate,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.slate,
        elevation: 0,
        centerTitle: false,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.indigo,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.indigo,
          side: const BorderSide(color: AppColors.indigo),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.indigo),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.indigo,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.creamDark,
        thickness: 1,
      ),
    );
  }
}
