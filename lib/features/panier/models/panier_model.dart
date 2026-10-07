/// Modèle d'une ligne individuelle du panier d'achat.
///
/// Conforme au DTO backend `PopulationLignePanierResponse.java`.
class LignePanierModel {
  final int ligneId;
  final int produitId;
  final String nomProduit;
  final String? forme;
  final String? photoUrl;
  final double prixUnitaire;
  final int quantite;
  final double sousTotal;
  final bool disponible;

  const LignePanierModel({
    required this.ligneId,
    required this.produitId,
    required this.nomProduit,
    this.forme,
    this.photoUrl,
    required this.prixUnitaire,
    required this.quantite,
    required this.sousTotal,
    this.disponible = true,
  });

  /// Prix unitaire formaté en FCFA.
  String get prixUnitaireFormate {
    final intValue = prixUnitaire.round();
    final formatted = intValue.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
    return '$formatted FCFA';
  }

  /// Sous-total formaté en FCFA.
  String get sousTotalFormate {
    final intValue = sousTotal.round();
    final formatted = intValue.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
    return '$formatted FCFA';
  }

  factory LignePanierModel.fromJson(Map<String, dynamic> json) {
    return LignePanierModel(
      ligneId: (json['ligneId'] as num?)?.toInt() ?? 0,
      produitId: (json['produitId'] as num?)?.toInt() ?? 0,
      nomProduit: json['nomProduit']?.toString() ?? 'Produit',
      forme: json['forme']?.toString(),
      photoUrl: json['photoUrl']?.toString(),
      prixUnitaire: (json['prixUnitaire'] as num?)?.toDouble() ?? 0.0,
      quantite: (json['quantite'] as num?)?.toInt() ?? 1,
      sousTotal: (json['sousTotal'] as num?)?.toDouble() ?? 0.0,
      disponible: json['disponible'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'ligneId': ligneId,
        'produitId': produitId,
        'nomProduit': nomProduit,
        'forme': forme,
        'photoUrl': photoUrl,
        'prixUnitaire': prixUnitaire,
        'quantite': quantite,
        'sousTotal': sousTotal,
        'disponible': disponible,
      };

  LignePanierModel copyWith({
    int? ligneId,
    int? produitId,
    String? nomProduit,
    String? forme,
    String? photoUrl,
    double? prixUnitaire,
    int? quantite,
    double? sousTotal,
    bool? disponible,
  }) {
    return LignePanierModel(
      ligneId: ligneId ?? this.ligneId,
      produitId: produitId ?? this.produitId,
      nomProduit: nomProduit ?? this.nomProduit,
      forme: forme ?? this.forme,
      photoUrl: photoUrl ?? this.photoUrl,
      prixUnitaire: prixUnitaire ?? this.prixUnitaire,
      quantite: quantite ?? this.quantite,
      sousTotal: sousTotal ?? this.sousTotal,
      disponible: disponible ?? this.disponible,
    );
  }
}

/// Modèle du panier d'achat complet.
///
/// Conforme au DTO backend `PopulationPanierResponse.java`.
class PanierModel {
  final int? panierId;
  final int nombreArticles;
  final double montantTotal;
  final DateTime? dateModification;
  final List<LignePanierModel> lignes;

  const PanierModel({
    this.panierId,
    this.nombreArticles = 0,
    this.montantTotal = 0.0,
    this.dateModification,
    this.lignes = const [],
  });

  bool get estVide => lignes.isEmpty;

  /// Montant total formaté en FCFA.
  String get montantTotalFormate {
    final intValue = montantTotal.round();
    final formatted = intValue.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
    return '$formatted FCFA';
  }

  factory PanierModel.fromJson(Map<String, dynamic> json) {
    return PanierModel(
      panierId: (json['panierId'] as num?)?.toInt(),
      nombreArticles: (json['nombreArticles'] as num?)?.toInt() ?? 0,
      montantTotal: (json['montantTotal'] as num?)?.toDouble() ?? 0.0,
      dateModification: json['dateModification'] != null
          ? DateTime.tryParse(json['dateModification'].toString())
          : null,
      lignes: (json['lignes'] as List<dynamic>?)
              ?.map((item) =>
                  LignePanierModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'panierId': panierId,
        'nombreArticles': nombreArticles,
        'montantTotal': montantTotal,
        'dateModification': dateModification?.toIso8601String(),
        'lignes': lignes.map((e) => e.toJson()).toList(),
      };

  factory PanierModel.vide() => const PanierModel(
        panierId: null,
        nombreArticles: 0,
        montantTotal: 0.0,
        lignes: [],
      );
}

