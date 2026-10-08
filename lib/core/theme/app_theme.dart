import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';

/// Configuration des thèmes officiels LADAFURA (Material 3)
/// Fournit [lightTheme] et [darkTheme] adaptés à l'identité visuelle de la pharmacopée malienne.
class AppTheme {
  AppTheme._();

  // ===========================================================================
  // ☀️ THÈME CLAIR (LIGHT THEME)
  // ===========================================================================
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.robotoTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryLight,
        onPrimaryContainer: AppColors.primaryDark,
        secondary: AppColors.accent,
        onSecondary: Colors.white,
        error: AppColors.danger,
        onError: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        outline: AppColors.border,
      ),

      // Typographie Roboto stricte (Light)
      textTheme: baseTextTheme.copyWith(
        displayLarge: AppTextStyles.h1,
        headlineLarge: AppTextStyles.h1,
        headlineMedium: AppTextStyles.h2,
        headlineSmall: AppTextStyles.h3,
        titleLarge: AppTextStyles.h3,
        titleMedium: AppTextStyles.h4,
        titleSmall: AppTextStyles.label,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.bodySecondary,
        bodySmall: AppTextStyles.caption,
        labelLarge: AppTextStyles.button,
        labelMedium: AppTextStyles.label,
        labelSmall: AppTextStyles.badge,
      ),

      // AppBar (Light)
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.h2,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),

      // Boutons principaux (Light)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(64, AppDimensions.buttonHeight),
          textStyle: AppTextStyles.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space16,
            vertical: AppDimensions.space12,
          ),
        ),
      ),

      // Boutons secondaires / outline (Light)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(64, AppDimensions.buttonHeight),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          textStyle: AppTextStyles.button.copyWith(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space16,
            vertical: AppDimensions.space12,
          ),
        ),
      ),

      // Champs de saisie (Light)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space16,
          vertical: AppDimensions.space12,
        ),
        hintStyle:
            AppTextStyles.bodySecondary.copyWith(color: AppColors.textMuted),
        labelStyle: AppTextStyles.label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          borderSide: const BorderSide(color: AppColors.border, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          borderSide: const BorderSide(color: AppColors.border, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
      ),

      // Cartes (Light)
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          side: const BorderSide(color: AppColors.border, width: 1.0),
        ),
      ),

      // Barre de navigation inférieure (Light)
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle:
            AppTextStyles.navigation.copyWith(color: AppColors.primary),
        unselectedLabelStyle: AppTextStyles.navigation,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  // ===========================================================================
  // 🌙 THÈME SOMBRE (DARK THEME)
  // ===========================================================================
  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.robotoTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.darkPrimary,
        onPrimary: AppColors.darkBackground,
        primaryContainer: AppColors.darkPrimaryContainer,
        onPrimaryContainer: AppColors.darkOnPrimaryContainer,
        secondary: AppColors.darkAccent,
        onSecondary: Colors.black,
        error: AppColors.darkDanger,
        onError: Colors.black,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        outline: AppColors.darkBorder,
      ),

      // Typographie Poppins stricte (Dark)
      textTheme: baseTextTheme.copyWith(
        displayLarge: AppTextStyles.h1Dark,
        headlineLarge: AppTextStyles.h1Dark,
        headlineMedium: AppTextStyles.h2Dark,
        headlineSmall: AppTextStyles.h3Dark,
        titleLarge: AppTextStyles.h3Dark,
        titleMedium: AppTextStyles.h4Dark,
        titleSmall: AppTextStyles.labelDark,
        bodyLarge: AppTextStyles.bodyDark,
        bodyMedium: AppTextStyles.bodySecondaryDark,
        bodySmall: AppTextStyles.captionDark,
        labelLarge:
            AppTextStyles.button.copyWith(color: AppColors.darkBackground),
        labelMedium: AppTextStyles.labelDark,
        labelSmall: AppTextStyles.badge,
      ),

      // AppBar (Dark)
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.h2Dark,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // Thème global des icônes (Dark Mode : blanc par défaut)
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),

      // Boutons principaux (Dark)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: AppColors.darkBackground,
          elevation: 0,
          minimumSize: const Size(64, AppDimensions.buttonHeight),
          textStyle: AppTextStyles.button.copyWith(
            color: AppColors.darkBackground,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space16,
            vertical: AppDimensions.space12,
          ),
        ),
      ),

      // Boutons secondaires / outline (Dark)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
          minimumSize: const Size(64, AppDimensions.buttonHeight),
          side: const BorderSide(color: AppColors.darkPrimary, width: 1.5),
          textStyle:
              AppTextStyles.button.copyWith(color: AppColors.darkPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space16,
            vertical: AppDimensions.space12,
          ),
        ),
      ),

      // Champs de saisie (Dark)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space16,
          vertical: AppDimensions.space12,
        ),
        hintStyle: AppTextStyles.bodySecondaryDark
            .copyWith(color: AppColors.darkTextMuted),
        labelStyle: AppTextStyles.labelDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          borderSide:
              const BorderSide(color: AppColors.darkPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          borderSide: const BorderSide(color: AppColors.darkDanger, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          borderSide: const BorderSide(color: AppColors.darkDanger, width: 1.5),
        ),
      ),

      // Cartes (Dark)
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          side: const BorderSide(color: AppColors.darkBorder, width: 1.0),
        ),
      ),

      // Barre de navigation inférieure (Dark)
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.darkPrimary,
        unselectedItemColor: AppColors.darkTextSecondary,
        selectedLabelStyle:
            AppTextStyles.navigation.copyWith(color: AppColors.darkPrimary),
        unselectedLabelStyle: AppTextStyles.navigationDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
