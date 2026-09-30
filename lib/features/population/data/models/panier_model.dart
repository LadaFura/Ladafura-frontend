/// Requête d'ajout d'un produit au panier (US-07).
class PopulationAddToCartRequestModel {
  final int produitId;
  final int quantite;

  const PopulationAddToCartRequestModel({
    required this.produitId,
    this.quantite = 1,
  });

  Map<String, dynamic> toJson() => {
        'produitId': produitId,
        'quantite': quantite,
      };
}

/// Requête de modification de la quantité d'un article.
class PopulationUpdateQuantityRequestModel {
  final int quantite;

  const PopulationUpdateQuantityRequestModel({required this.quantite});

  Map<String, dynamic> toJson() => {
        'quantite': quantite,
      };
}

/// Ligne individuelle d'un article dans le panier d'achat.
class PopulationLignePanierModel {
  final int ligneId;
  final int produitId;
  final String nomProduit;
  final String? forme;
  final String? photoUrl;
  final double prixUnitaire;
  final int quantite;
  final double sousTotal;
  final bool disponible;

  const PopulationLignePanierModel({
    required this.ligneId,
    required this.produitId,
    required this.nomProduit,
    this.forme,
    this.photoUrl,
    required this.prixUnitaire,
    this.quantite = 1,
    required this.sousTotal,
    this.disponible = true,
  });

  PopulationLignePanierModel copyWith({
    int? quantite,
    double? sousTotal,
  }) {
    return PopulationLignePanierModel(
      ligneId: ligneId,
      produitId: produitId,
      nomProduit: nomProduit,
      forme: forme,
      photoUrl: photoUrl,
      prixUnitaire: prixUnitaire,
      quantite: quantite ?? this.quantite,
      sousTotal: sousTotal ?? (prixUnitaire * (quantite ?? this.quantite)),
      disponible: disponible,
    );
  }

  factory PopulationLignePanierModel.fromJson(Map<String, dynamic> json) {
    final pu = (json['prixUnitaire'] as num?)?.toDouble() ?? 0.0;
    final q = json['quantite'] as int? ?? 1;
    final st = (json['sousTotal'] as num?)?.toDouble() ?? (pu * q);

    return PopulationLignePanierModel(
      ligneId: json['ligneId'] as int? ?? 0,
      produitId: json['produitId'] as int? ?? 0,
      nomProduit: json['nomProduit'] as String? ?? '',
      forme: json['forme'] as String?,
      photoUrl: json['photoUrl'] as String?,
      prixUnitaire: pu,
      quantite: q,
      sousTotal: st,
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
}

/// Panier d'achat actif de l'utilisateur (US-07).
class PopulationPanierModel {
  final int? panierId;
  final int nombreArticles;
  final double montantTotal;
  final DateTime? dateModification;
  final List<PopulationLignePanierModel> lignes;

  const PopulationPanierModel({
    this.panierId,
    this.nombreArticles = 0,
    this.montantTotal = 0.0,
    this.dateModification,
    this.lignes = const [],
  });

  bool get isEmpty => lignes.isEmpty;
  bool get isNotEmpty => lignes.isNotEmpty;

  factory PopulationPanierModel.empty() => const PopulationPanierModel();

  factory PopulationPanierModel.fromJson(Map<String, dynamic> json) {
    final list = (json['lignes'] as List<dynamic>?)
            ?.map((e) =>
                PopulationLignePanierModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final total = (json['montantTotal'] as num?)?.toDouble() ??
        list.fold<double>(0.0, (acc, item) => acc + item.sousTotal);
    final count = json['nombreArticles'] as int? ??
        list.fold<int>(0, (acc, item) => acc + item.quantite);

    return PopulationPanierModel(
      panierId: json['panierId'] as int?,
      nombreArticles: count,
      montantTotal: total,
      dateModification: json['dateModification'] != null
          ? DateTime.tryParse(json['dateModification'].toString())
          : null,
      lignes: list,
    );
  }

  Map<String, dynamic> toJson() => {
        if (panierId != null) 'panierId': panierId,
        'nombreArticles': nombreArticles,
        'montantTotal': montantTotal,
        if (dateModification != null)
          'dateModification': dateModification!.toIso8601String(),
        'lignes': lignes.map((e) => e.toJson()).toList(),
      };
}
