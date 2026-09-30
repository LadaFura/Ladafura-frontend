/// Modes de retrait disponibles pour la réception des produits (US-09 & US-22).
///
/// Conforme à `com.pharmacopee.ladafura.enums.TypeModeRetrait` du backend Spring Boot.
enum ModeRetraitType {
  /// Retrait direct en officine / pharmacopée partenaire (Gratuit).
  pickup,

  /// Livraison à domicile ou à l'adresse spécifiée (Payant).
  livraison;

  /// Valeur textuelle exacte attendue par les APIs Spring Boot.
  String get value {
    switch (this) {
      case ModeRetraitType.pickup:
        return 'PICKUP';
      case ModeRetraitType.livraison:
        return 'LIVRAISON';
    }
  }

  /// Libellé convivial en français.
  String get label {
    switch (this) {
      case ModeRetraitType.pickup:
        return 'Retrait en officine (Gratuit)';
      case ModeRetraitType.livraison:
        return 'Livraison à domicile';
    }
  }

  /// Nom court pour badges et synthèses.
  String get shortLabel {
    switch (this) {
      case ModeRetraitType.pickup:
        return 'Pickup Officine';
      case ModeRetraitType.livraison:
        return 'Livraison';
    }
  }

  /// Indique si ce mode engendre habituellement des frais de transport.
  bool get hasDeliveryFee => this == ModeRetraitType.livraison;

  /// Parse un mode de retrait depuis une chaîne (tolère les alias du cahier des charges).
  static ModeRetraitType? fromString(String? str) {
    if (str == null || str.isEmpty) return null;
    final normalized = str.trim().toUpperCase();
    for (final m in ModeRetraitType.values) {
      if (m.value == normalized) return m;
    }
    // Alias usuels du cahier des charges
    if (normalized == 'RETRAIT_OFFICINE' || normalized == 'RETRAIT') {
      return ModeRetraitType.pickup;
    }
    if (normalized == 'LIVRAISON_DOMICILE') {
      return ModeRetraitType.livraison;
    }
    return null;
  }
}
