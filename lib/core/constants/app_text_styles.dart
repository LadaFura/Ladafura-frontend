import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Hiérarchie typographique officielle LADAFURA
/// Police exclusive : Roboto (Google Fonts)
/// Écran de référence mobile : 402 × 874 px
/// Échelle stricte à 7 tailles : 12 / 14 / 16 / 18 / 20 / 24 / 28 px
/// Poids : 400 (Regular), 500 (Medium), 600 (SemiBold), 700 (Bold)
/// Texte normal (sans italique) pour une clarté et lisibilité optimales.
class AppTextStyles {
  AppTextStyles._();

  // ===========================================================================
  // 1. TITRES (HEADINGS) - LIGHT
  // ===========================================================================

  /// H1 : Titre principal de l'écran (28 px / 700 Bold)
  static TextStyle get h1 => GoogleFonts.roboto(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: AppColors.textPrimary,
      );

  /// H2 : Titres de sections et titres de pages secondaires (24 px / 600 SemiBold)
  static TextStyle get h2 => GoogleFonts.roboto(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: AppColors.textPrimary,
      );

  /// H3 : Sous-titres et sections importantes (20 px / 600 SemiBold)
  static TextStyle get h3 => GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: AppColors.textPrimary,
      );

  /// H4 : Titres de cartes, noms de produits et pharmacopées (18 px / 600 SemiBold)
  static TextStyle get h4 => GoogleFonts.roboto(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: AppColors.textPrimary,
      );

  // ===========================================================================
  // 1. TITRES (HEADINGS) - DARK
  // ===========================================================================

  /// H1 Dark (28 px / 700 Bold)
  static TextStyle get h1Dark => h1.copyWith(color: AppColors.darkTextPrimary);

  /// H2 Dark (24 px / 600 SemiBold)
  static TextStyle get h2Dark => h2.copyWith(color: AppColors.darkTextPrimary);

  /// H3 Dark (20 px / 600 SemiBold)
  static TextStyle get h3Dark => h3.copyWith(color: AppColors.darkTextPrimary);

  /// H4 Dark (18 px / 600 SemiBold)
  static TextStyle get h4Dark => h4.copyWith(color: AppColors.darkTextPrimary);

  // ===========================================================================
  // 2. CORPS DE TEXTE (BODY) - LIGHT & DARK
  // ===========================================================================

  /// Texte principal (16 px / 400 Regular)
  static TextStyle get body => GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.textPrimary,
      );

  /// Texte principal Dark (16 px / 400 Regular)
  static TextStyle get bodyDark =>
      body.copyWith(color: AppColors.darkTextPrimary);

  /// Texte secondaire (14 px / 400 Regular)
  static TextStyle get bodySecondary => GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: AppColors.textSecondary,
      );

  /// Texte secondaire Dark (14 px / 400 Regular)
  static TextStyle get bodySecondaryDark =>
      bodySecondary.copyWith(color: AppColors.darkTextSecondary);

  // ===========================================================================
  // 3. LABELS, BOUTONS & NAVIGATION
  // ===========================================================================

  /// Labels de formulaires et indications (14 px / 500 Medium)
  static TextStyle get label => GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: AppColors.textPrimary,
      );

  /// Labels de formulaires Dark (14 px / 500 Medium)
  static TextStyle get labelDark =>
      label.copyWith(color: AppColors.darkTextPrimary);

  /// Boutons d'action (15 px / 500 Medium)
  static TextStyle get button => GoogleFonts.roboto(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.2,
        letterSpacing: 0.2,
        color: Colors.white,
      );

  /// Navigation et onglets (14 px / 500 Medium)
  static TextStyle get navigation => GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.2,
        color: AppColors.textSecondary,
      );

  /// Navigation Dark (14 px / 500 Medium)
  static TextStyle get navigationDark =>
      navigation.copyWith(color: AppColors.darkTextSecondary);

  // ===========================================================================
  // 4. PRIX & VALEURS FINANCIÈRES
  // ===========================================================================

  /// Prix importants (18 px / 600 SemiBold) - Light
  static TextStyle get priceLarge => GoogleFonts.roboto(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: AppColors.primaryDark,
      );

  /// Prix importants (18 px / 600 SemiBold) - Dark
  static TextStyle get priceLargeDark => GoogleFonts.roboto(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: AppColors.darkPrimary,
      );

  /// Prix standards (16 px / 600 SemiBold) - Light
  static TextStyle get priceMedium => GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: AppColors.textPrimary,
      );

  /// Prix standards (16 px / 600 SemiBold) - Dark
  static TextStyle get priceMediumDark => GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: AppColors.darkTextPrimary,
      );

  // ===========================================================================
  // 5. CAPTIONS, BADGES & STATUTS (12 px)
  // ===========================================================================

  /// Badges et statuts certifiés (12 px / 500 Medium)
  static TextStyle get badge => GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.2,
        letterSpacing: 0.1,
      );

  /// Caption et aide (12 px / 400 Regular) - Light
  static TextStyle get caption => GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.35,
        color: AppColors.textSecondary,
      );

  /// Caption et aide (12 px / 400 Regular) - Dark
  static TextStyle get captionDark =>
      caption.copyWith(color: AppColors.darkTextSecondary);
}
