/// Méthodes de paiement acceptées pour les commandes de remèdes traditionnels (US-10).
///
/// Conforme à `com.pharmacopee.ladafura.enums.MethodePaiement` du backend Spring Boot.
enum MethodePaiement {
  mobileMoney,
  cash,
  carteBancaire;

  /// Valeur textuelle exacte attendue par les APIs Spring Boot.
  String get value {
    switch (this) {
      case MethodePaiement.mobileMoney:
        return 'MOBILE_MONEY';
      case MethodePaiement.cash:
        return 'CASH';
      case MethodePaiement.carteBancaire:
        return 'CARTE_BANCAIRE';
    }
  }

  /// Libellé convivial en français pour l'utilisateur.
  String get label {
    switch (this) {
      case MethodePaiement.mobileMoney:
        return 'Mobile Money (Orange / Wave / Moov)';
      case MethodePaiement.cash:
        return 'Paiement en espèces (Cash)';
      case MethodePaiement.carteBancaire:
        return 'Carte bancaire (Visa / Mastercard)';
    }
  }

  /// Nom court pour l'affichage synthétique.
  String get shortLabel {
    switch (this) {
      case MethodePaiement.mobileMoney:
        return 'Mobile Money';
      case MethodePaiement.cash:
        return 'Espèces';
      case MethodePaiement.carteBancaire:
        return 'Carte bancaire';
    }
  }

  /// Indique si le paiement nécessite un transfert digital préalable.
  bool get isDigital =>
      this == MethodePaiement.mobileMoney ||
      this == MethodePaiement.carteBancaire;

  /// Parse une méthode de paiement depuis une chaîne.
  static MethodePaiement? fromString(String? str) {
    if (str == null || str.isEmpty) return null;
    final normalized = str.trim().toUpperCase();
    for (final m in MethodePaiement.values) {
      if (m.value == normalized) return m;
    }
    if (normalized == 'ESPECES') return MethodePaiement.cash;
    return null;
  }
}
