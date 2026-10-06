/// DTO pour une plante entrant dans la composition d'un produit.
/// Conforme à `PopulationCompositionItemDto.java`.
class CompositionItemModel {
  final int planteId;
  final String nomScientifique;
  final List<String> nomsVernaculaires;
  final double quantite;
  final String unite;
  final String? photoUrl;

  const CompositionItemModel({
    required this.planteId,
    required this.nomScientifique,
    this.nomsVernaculaires = const [],
    required this.quantite,
    required this.unite,
    this.photoUrl,
  });

  factory CompositionItemModel.fromJson(Map<String, dynamic> json) {
    return CompositionItemModel(
      planteId: (json['planteId'] as num?)?.toInt() ?? 0,
      nomScientifique: json['nomScientifique']?.toString() ?? '',
      nomsVernaculaires: (json['nomsVernaculaires'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      quantite: (json['quantite'] as num?)?.toDouble() ?? 0.0,
      unite: json['unite']?.toString() ?? '',
      photoUrl: json['photoUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'planteId': planteId,
        'nomScientifique': nomScientifique,
        'nomsVernaculaires': nomsVernaculaires,
        'quantite': quantite,
        'unite': unite,
        'photoUrl': photoUrl,
      };
}

/// DTO pour une maladie / indication liée au produit.
/// Conforme à `PopulationProduitMaladieDto.java`.
class ProduitMaladieModel {
  final int id;
  final String nom;
  final String? description;

  const ProduitMaladieModel({
    required this.id,
    required this.nom,
    this.description,
  });

  factory ProduitMaladieModel.fromJson(Map<String, dynamic> json) {
    return ProduitMaladieModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nom: json['nom']?.toString() ?? '',
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'description': description,
      };
}

/// Modèle complet du détail d'un produit traditionnel.
/// Conforme à `PopulationProduitDetailResponse.java`.
class ProduitDetailModel {
  final int id;
  final String nom;
  final String? description;
  final String? forme;
  final String? compositionTexte;
  final double prixIndicatif;
  final String? photoUrl;
  final int? categorieId;
  final String? categorieNom;
  final double noteMoyenne;
  final int nombreAvis;
  final List<CompositionItemModel> compositions;
  final List<ProduitMaladieModel> maladies;

  const ProduitDetailModel({
    required this.id,
    required this.nom,
    this.description,
    this.forme,
    this.compositionTexte,
    required this.prixIndicatif,
    this.photoUrl,
    this.categorieId,
    this.categorieNom,
    this.noteMoyenne = 0.0,
    this.nombreAvis = 0,
    this.compositions = const [],
    this.maladies = const [],
  });

  String get prixFormate {
    final intValue = prixIndicatif.round();
    final formatted = intValue.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
    return '$formatted FCFA';
  }

  factory ProduitDetailModel.fromJson(Map<String, dynamic> json) {
    return ProduitDetailModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nom: json['nom']?.toString() ?? 'Remède Traditionnel',
      description: json['description']?.toString(),
      forme: json['forme']?.toString(),
      compositionTexte: json['compositionTexte']?.toString(),
      prixIndicatif: (json['prixIndicatif'] as num?)?.toDouble() ?? 0.0,
      photoUrl: json['photoUrl']?.toString(),
      categorieId: (json['categorieId'] as num?)?.toInt(),
      categorieNom: json['categorieNom']?.toString() ?? 'Phytothérapie',
      noteMoyenne: (json['noteMoyenne'] as num?)?.toDouble() ?? 0.0,
      nombreAvis: (json['nombreAvis'] as num?)?.toInt() ?? 0,
      compositions: (json['compositions'] as List<dynamic>?)
              ?.map((e) => CompositionItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      maladies: (json['maladies'] as List<dynamic>?)
              ?.map((e) => ProduitMaladieModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

