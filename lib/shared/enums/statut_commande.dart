import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Statuts du cycle de vie d'une commande client (US-08 à US-11 & US-23).
///
/// Conforme à `com.pharmacopee.ladafura.enums.StatutCommande` du backend Spring Boot.
enum StatutCommande {
  enAttente,
  confirmee,
  preparee,
  enLivraison,
  disponiblePickup,
  livree,
  retiree,
  annulee;

  /// Valeur textuelle exacte attendue par les APIs Spring Boot.
  String get value {
    switch (this) {
      case StatutCommande.enAttente:
        return 'EN_ATTENTE';
      case StatutCommande.confirmee:
        return 'CONFIRMEE';
      case StatutCommande.preparee:
        return 'PREPAREE';
      case StatutCommande.enLivraison:
        return 'EN_LIVRAISON';
      case StatutCommande.disponiblePickup:
        return 'DISPONIBLE_PICKUP';
      case StatutCommande.livree:
        return 'LIVREE';
      case StatutCommande.retiree:
        return 'RETIREE';
      case StatutCommande.annulee:
        return 'ANNULEE';
    }
  }

  /// Libellé convivial en français pour l'utilisateur.
  String get label {
    switch (this) {
      case StatutCommande.enAttente:
        return 'En attente';
      case StatutCommande.confirmee:
        return 'Validée';
      case StatutCommande.preparee:
        return 'Préparée';
      case StatutCommande.enLivraison:
        return 'En cours de livraison';
      case StatutCommande.disponiblePickup:
        return 'Prête au retrait';
      case StatutCommande.livree:
        return 'Livrée';
      case StatutCommande.retiree:
        return 'Retirée';
      case StatutCommande.annulee:
        return 'Annulée';
    }
  }

  /// Couleur de badge conforme à la charte ENF11.
  Color get badgeColor {
    switch (this) {
      case StatutCommande.enAttente:
        return AppColors.warning;
      case StatutCommande.confirmee:
      case StatutCommande.preparee:
        return AppColors.info;
      case StatutCommande.enLivraison:
      case StatutCommande.disponiblePickup:
        return AppColors.accent;
      case StatutCommande.livree:
      case StatutCommande.retiree:
        return AppColors.success;
      case StatutCommande.annulee:
        return AppColors.danger;
    }
  }

  /// Indique si la commande est terminée (succès ou annulation).
  bool get isCompleted =>
      this == StatutCommande.livree ||
      this == StatutCommande.retiree ||
      this == StatutCommande.annulee;

  /// Indique si la commande est en cours de traitement.
  bool get isInProgress => !isCompleted;

  /// Parse un statut depuis une chaîne (tolère les alias du cahier des charges).
  static StatutCommande? fromString(String? str) {
    if (str == null || str.isEmpty) return null;
    final normalized = str.trim().toUpperCase();
    for (final s in StatutCommande.values) {
      if (s.value == normalized) return s;
    }
    // Alias usuels
    if (normalized == 'VALIDEE') return StatutCommande.confirmee;
    if (normalized == 'EXPEDIEE') return StatutCommande.enLivraison;
    return null;
  }
}
