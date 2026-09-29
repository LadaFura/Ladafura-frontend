import 'package:flutter/material.dart';

/// Palette de couleurs officielle du Design System LADAFURA.
///
/// Comprend la palette Thème Clair (Light Mode) et Thème Sombre (Dark Mode),
/// conçue pour la plateforme nationale de pharmacopée et médecine traditionnelle du Mali (INRMPT).
/// Respecte les contrastes d'accessibilité WCAG AA/AAA.
class AppColors {
  AppColors._();

  // ===========================================================================
  // ☀️ THÈME CLAIR (LIGHT MODE) - OFFICIEL
  // ===========================================================================

  // --- Couleurs Principales ---
  /// Vert médicinal principal (#2E7D32)
  static const Color primary = Color(0xFF2E7D32);

  /// Vert forêt profond pour contrastes et en-têtes (#14532D)
  static const Color primaryDark = Color(0xFF14532D);

  /// Vert menthe doux pour conteneurs et cartes (#E8F5E9)
  static const Color primaryLight = Color(0xFFE8F5E9);

  /// Ocre / Ambre doré pour les actions commerciales et points d'attention (#F4A621)
  static const Color accent = Color(0xFFF4A621);

  // --- Typographie & Textes ---
  /// Texte principal à forte lisibilité (#17251C)
  static const Color textPrimary = Color(0xFF17251C);

  /// Texte secondaire, noms scientifiques et sous-titres (#475569)
  static const Color textSecondary = Color(0xFF475569);

  /// Texte tertiaire / placeholders (#94A3B8)
  static const Color textMuted = Color(0xFF94A3B8);

  // --- Surfaces, Fonds & Bordures ---
  /// Blanc pur pour cartes et surfaces élevées (#FFFFFF)
  static const Color surface = Color(0xFFFFFFFF);

  /// Surface subtile / cartes secondaires (#F1F5F2)
  static const Color surfaceVariant = Color(0xFFF1F5F2);

  /// Fond d'écran global sobre (#F8FAFC)
  static const Color background = Color(0xFFF8FAFC);

  /// Bordures douces, séparateurs et contours de champs (#DDE5E0)
  static const Color border = Color(0xFFDDE5E0);

  // --- Actions & Feedback ---
  /// Action destructive, bouton supprimer, alerte de rejet (#DC2626)
  static const Color danger = Color(0xFFDC2626);

  /// Succès et validation (#16A34A)
  static const Color success = Color(0xFF16A34A);

  /// Avertissement (#F59E0B)
  static const Color warning = Color(0xFFF59E0B);

  /// Information (#2563EB)
  static const Color info = Color(0xFF2563EB);

  // --- Badges & Statuts Certifiés (ENF11) - Light ---
  // 1. Usage traditionnel rapporté
  static const Color badgeTraditionnelBg = Color(0xFFE8F5E9);
  static const Color badgeTraditionnelDot = Color(0xFF2E7D32);
  static const Color badgeTraditionnelText = Color(0xFF2E7D32);

  // 2. Étude scientifique disponible
  static const Color badgeScientifiqueBg = Color(0xFFEFF6FF);
  static const Color badgeScientifiqueDot = Color(0xFF2563EB);
  static const Color badgeScientifiqueText = Color(0xFF2563EB);

  // 3. Information institutionnelle
  static const Color badgeInstitutionnelBg = Color(0xFFFEF3C7);
  static const Color badgeInstitutionnelDot = Color(0xFFF4A621);
  static const Color badgeInstitutionnelText = Color(0xFFB45309);

  // 4. En cours de vérification
  static const Color badgeVerificationBg = Color(0xFFFEF9C3);
  static const Color badgeVerificationDot = Color(0xFFCA8A04);
  static const Color badgeVerificationText = Color(0xFFA16207);

  // ===========================================================================
  // 🌙 THÈME SOMBRE (DARK MODE) - VERT FORÊT BOTANIQUE / MIDNIGHT FOREST
  // Conçu pour un confort visuel optimal, éliminant le noir agressif au profit
  // d'un vert forêt / médicinal profond ("vert qui se rapproche du noir"), reposant
  // pour les yeux et en parfaite harmonie avec la pharmacopée malienne (INRMPT).
  // ===========================================================================

  // --- Couleurs Principales (Dark) ---
  /// Vert émeraude médicinal éclatant et apaisé (#34D399)
  static const Color darkPrimary = Color(0xFF34D399);

  /// Vert forêt profond (#059669)
  static const Color darkPrimaryDark = Color(0xFF059669);

  /// Fond teinté vert végétal pour conteneurs (#1E4334)
  static const Color darkPrimaryContainer = Color(0xFF1E4334);

  /// Texte / icônes sur conteneur primaire sombre (#A7F3D0)
  static const Color darkOnPrimaryContainer = Color(0xFFA7F3D0);

  /// Ocre / ambre lumineux pour actions en mode sombre (#FBBF24)
  static const Color darkAccent = Color(0xFFFBBF24);

  // --- Typographie & Textes (Dark) ---
  /// Blanc menthe lumineux à très forte lisibilité (#F0FDF4)
  static const Color darkTextPrimary = Color(0xFFF0FDF4);

  /// Texte secondaire vert sauge argenté (#9CB8A9)
  static const Color darkTextSecondary = Color(0xFF9CB8A9);

  /// Texte tertiaire / placeholders en mode sombre (#6B8B7B)
  static const Color darkTextMuted = Color(0xFF6B8B7B);

  // --- Surfaces, Fonds & Bordures (Dark : Vert Forêt Botanique) ---
  /// Fond d'écran global vert forêt profond adouci, proche du noir (#0F231A)
  static const Color darkBackground = Color(0xFF0F231A);

  /// Surface sombre principale en vert forêt pour cartes, modales et dock (#193327)
  static const Color darkSurface = Color(0xFF193327);

  /// Surface surélevée ou cartes alternées (#244234)
  static const Color darkSurfaceVariant = Color(0xFF244234);

  /// Bordures douces en vert sauge profond (#2E5241)
  static const Color darkBorder = Color(0xFF2E5241);

  // --- Actions & Feedback (Dark) ---
  /// Alerte / action destructive lumineuse (#F87171)
  static const Color darkDanger = Color(0xFFF87171);

  /// Succès lumineux (#34D399)
  static const Color darkSuccess = Color(0xFF34D399);

  /// Avertissement lumineux (#FBBF24)
  static const Color darkWarning = Color(0xFFFBBF24);

  /// Information lumineuse (#60A5FA)
  static const Color darkInfo = Color(0xFF60A5FA);

  // --- Badges & Statuts Certifiés (ENF11) - Dark ---
  // 1. Usage traditionnel rapporté (Dark)
  static const Color darkBadgeTraditionnelBg = Color(0xFF1B3D2F);
  static const Color darkBadgeTraditionnelDot = Color(0xFF34D399);
  static const Color darkBadgeTraditionnelText = Color(0xFF6EE7B7);

  // 2. Étude scientifique disponible (Dark)
  static const Color darkBadgeScientifiqueBg = Color(0xFF173042);
  static const Color darkBadgeScientifiqueDot = Color(0xFF60A5FA);
  static const Color darkBadgeScientifiqueText = Color(0xFF93C5FD);

  // 3. Information institutionnelle (Dark)
  static const Color darkBadgeInstitutionnelBg = Color(0xFF3B2A15);
  static const Color darkBadgeInstitutionnelDot = Color(0xFFFBBF24);
  static const Color darkBadgeInstitutionnelText = Color(0xFFFCD34D);

  // 4. En cours de vérification (Dark)
  static const Color darkBadgeVerificationBg = Color(0xFF383212);
  static const Color darkBadgeVerificationDot = Color(0xFFFACC15);
  static const Color darkBadgeVerificationText = Color(0xFFFEF08A);
}
