import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Statuts du cycle de vie d'une collecte de terrain (US-13 & US-17).
///
/// Conforme à `com.pharmacopee.ladafura.enums.StatutCollecte` du backend Spring Boot.
enum StatutCollecte {
  brouillon,
  soumise,
  enExamen,
  validee,
  rejetee,
  correctionDemandee;

  /// Valeur textuelle exacte attendue par les APIs Spring Boot.
  String get value {
    switch (this) {
      case StatutCollecte.brouillon:
        return 'BROUILLON';
      case StatutCollecte.soumise:
        return 'SOUMISE';
      case StatutCollecte.enExamen:
        return 'EN_EXAMEN';
      case StatutCollecte.validee:
        return 'VALIDEE';
      case StatutCollecte.rejetee:
        return 'REJETEE';
      case StatutCollecte.correctionDemandee:
        return 'CORRECTION_DEMANDEE';
    }
  }

  /// Libellé convivial en français pour l'affichage dans les badges.
  String get label {
    switch (this) {
      case StatutCollecte.brouillon:
        return 'Brouillon';
      case StatutCollecte.soumise:
        return 'Soumise';
      case StatutCollecte.enExamen:
        return 'En examen';
      case StatutCollecte.validee:
        return 'Validée';
      case StatutCollecte.rejetee:
        return 'Rejetée';
      case StatutCollecte.correctionDemandee:
        return 'À corriger';
    }
  }

  /// Couleur de badge conforme à la charte ENF11.
  Color get badgeColor {
    switch (this) {
      case StatutCollecte.brouillon:
        return AppColors.textMuted;
      case StatutCollecte.soumise:
      case StatutCollecte.enExamen:
        return AppColors.info;
      case StatutCollecte.validee:
        return AppColors.success;
      case StatutCollecte.rejetee:
        return AppColors.danger;
      case StatutCollecte.correctionDemandee:
        return AppColors.warning;
    }
  }

  /// Indique si la collecte peut être éditée ou modifiée par l'agent.
  bool get canEdit =>
      this == StatutCollecte.brouillon ||
      this == StatutCollecte.correctionDemandee;

  /// Parse un statut depuis une chaîne (tolère la casse et les alias).
  static StatutCollecte? fromString(String? str) {
    if (str == null || str.isEmpty) return null;
    final normalized = str.trim().toUpperCase();
    for (final s in StatutCollecte.values) {
      if (s.value == normalized) return s;
    }
    if (normalized == 'A_CORRIGER') return StatutCollecte.correctionDemandee;
    return null;
  }
}
