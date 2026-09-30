import 'package:ladafura_frontend_flutter/shared/models/produit_sommaire_model.dart';

/// Mode de retrait proposé par une officine (LIVRAISON ou PICKUP).
class PopulationModeRetraitModel {
  final int id;
  final String type; // LIVRAISON, PICKUP
  final bool actif;
  final double frais;

  const PopulationModeRetraitModel({
    required this.id,
    required this.type,
    this.actif = true,
    this.frais = 0.0,
  });

  bool get isLivraison => type.toUpperCase() == 'LIVRAISON';
  bool get isPickup => type.toUpperCase() == 'PICKUP';

  factory PopulationModeRetraitModel.fromJson(Map<String, dynamic> json) {
    return PopulationModeRetraitModel(
      id: json['id'] as int? ?? 0,
      type: json['type'] as String? ?? 'PICKUP',
      actif: json['actif'] as bool? ?? true,
      frais: (json['frais'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'actif': actif,
        'frais': frais,
      };
}

/// Plante entrant dans la composition d'un produit traditionnel.
class PopulationCompositionItemModel {
  final int? planteId;
  final String nomScientifique;
  final List<String> nomsVernaculaires;
  final double? quantite;
  final String? unite;

  const PopulationCompositionItemModel({
    this.planteId,
    required this.nomScientifique,
    this.nomsVernaculaires = const [],
    this.quantite,
    this.unite,
  });

  factory PopulationCompositionItemModel.fromJson(Map<String, dynamic> json) {
    return PopulationCompositionItemModel(
      planteId: json['planteId'] as int?,
      nomScientifique: json['nomScientifique'] as String? ?? '',
      nomsVernaculaires: (json['nomsVernaculaires'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      quantite: (json['quantite'] as num?)?.toDouble(),
      unite: json['unite'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (planteId != null) 'planteId': planteId,
        'nomScientifique': nomScientifique,
        'nomsVernaculaires': nomsVernaculaires,
        if (quantite != null) 'quantite': quantite,
        if (unite != null) 'unite': unite,
      };
}

/// Offre commerciale d'une pharmacopée agréée pour un produit (prix, disponibilité, modes de retrait).
class PopulationOffrePharmacopeeModel {
  final int? disponibiliteId;
  final int pharmacopeeId;
  final String nomPharmacopee;
  final String? telephone;
  final String? region;
  final String? cercle;
  final String? commune;
  final String? localite;
  final double? latitude;
  final double? longitude;
  final bool disponible;
  final int quantiteStock;
  final double prix;
  final List<PopulationModeRetraitModel> modesRetrait;

  const PopulationOffrePharmacopeeModel({
    this.disponibiliteId,
    required this.pharmacopeeId,
    required this.nomPharmacopee,
    this.telephone,
    this.region,
    this.cercle,
    this.commune,
    this.localite,
    this.latitude,
    this.longitude,
    this.disponible = true,
    this.quantiteStock = 0,
    required this.prix,
    this.modesRetrait = const [],
  });

  factory PopulationOffrePharmacopeeModel.fromJson(Map<String, dynamic> json) {
    return PopulationOffrePharmacopeeModel(
      disponibiliteId: json['disponibiliteId'] as int?,
      pharmacopeeId: json['pharmacopeeId'] as int? ?? 0,
      nomPharmacopee: json['nomPharmacopee'] as String? ?? '',
      telephone: json['telephone'] as String?,
      region: json['region'] as String?,
      cercle: json['cercle'] as String?,
      commune: json['commune'] as String?,
      localite: json['localite'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      disponible: json['disponible'] as bool? ?? true,
      quantiteStock: json['quantiteStock'] as int? ?? 0,
      prix: (json['prix'] as num?)?.toDouble() ?? 0.0,
      modesRetrait: (json['modesRetrait'] as List<dynamic>?)
              ?.map((e) => PopulationModeRetraitModel.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        if (disponibiliteId != null) 'disponibiliteId': disponibiliteId,
        'pharmacopeeId': pharmacopeeId,
        'nomPharmacopee': nomPharmacopee,
        'telephone': telephone,
        'region': region,
        'cercle': cercle,
        'commune': commune,
        'localite': localite,
        'latitude': latitude,
        'longitude': longitude,
        'disponible': disponible,
        'quantiteStock': quantiteStock,
        'prix': prix,
        'modesRetrait': modesRetrait.map((e) => e.toJson()).toList(),
      };
}

/// Aperçu synthétique d'un produit pour les listes et catalogues (US-04, US-06).
class PopulationProduitSummaryModel {
  final int id;
  final String nom;
  final String? description;
  final String? forme;
  final double prixIndicatif;
  final String? photoUrl;
  final int? categorieId;
  final String? categorieNom;
  final List<String> plantesPrincipales;
  final int nombrePharmacopees;
  final bool disponibleEnPharmacie;
  final double? noteMoyenne;
  final int nombreAvis;

  const PopulationProduitSummaryModel({
    required this.id,
    required this.nom,
    this.description,
    this.forme,
    required this.prixIndicatif,
    this.photoUrl,
    this.categorieId,
    this.categorieNom,
    this.plantesPrincipales = const [],
    this.nombrePharmacopees = 0,
    this.disponibleEnPharmacie = true,
    this.noteMoyenne,
    this.nombreAvis = 0,
  });

  ProduitSommaireModel toSommaire() {
    return ProduitSommaireModel(
      id: id,
      nom: nom,
      description: description,
      prixIndicatif: prixIndicatif,
      photoUrl: photoUrl,
      forme: forme,
      categorieId: categorieId,
      categorieNom: categorieNom,
      plantesPrincipales: plantesPrincipales,
      nombrePharmacopees: nombrePharmacopees,
      disponibleEnPharmacie: disponibleEnPharmacie,
      noteMoyenne: noteMoyenne,
      nombreAvis: nombreAvis,
    );
  }

  factory PopulationProduitSummaryModel.fromJson(Map<String, dynamic> json) {
    return PopulationProduitSummaryModel(
      id: json['id'] as int? ?? 0,
      nom: json['nom'] as String? ?? '',
      description: json['description'] as String?,
      forme: json['forme'] as String?,
      prixIndicatif: (json['prixIndicatif'] as num?)?.toDouble() ?? 0.0,
      photoUrl: json['photoUrl'] as String?,
      categorieId: json['categorieId'] as int?,
      categorieNom: json['categorieNom'] as String?,
      plantesPrincipales: (json['plantesPrincipales'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      nombrePharmacopees: json['nombrePharmacopees'] as int? ?? 0,
      disponibleEnPharmacie: json['disponibleEnPharmacie'] as bool? ?? true,
      noteMoyenne: (json['noteMoyenne'] as num?)?.toDouble(),
      nombreAvis: json['nombreAvis'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'description': description,
        'forme': forme,
        'prixIndicatif': prixIndicatif,
        'photoUrl': photoUrl,
        'categorieId': categorieId,
        'categorieNom': categorieNom,
        'plantesPrincipales': plantesPrincipales,
        'nombrePharmacopees': nombrePharmacopees,
        'disponibleEnPharmacie': disponibleEnPharmacie,
        'noteMoyenne': noteMoyenne,
        'nombreAvis': nombreAvis,
      };
}

/// Fiche détaillée complète d'un produit traditionnel (US-04).
class PopulationProduitDetailModel {
  final int id;
  final String nom;
  final String? description;
  final String? forme;
  final String? compositionTexte;
  final double prixIndicatif;
  final String? photoUrl;
  final int? categorieId;
  final String? categorieNom;
  final double? noteMoyenne;
  final int nombreAvis;
  final List<PopulationCompositionItemModel> compositions;
  final List<String> maladies;
  final List<PopulationOffrePharmacopeeModel> offresPharmacopees;

  const PopulationProduitDetailModel({
    required this.id,
    required this.nom,
    this.description,
    this.forme,
    this.compositionTexte,
    required this.prixIndicatif,
    this.photoUrl,
    this.categorieId,
    this.categorieNom,
    this.noteMoyenne,
    this.nombreAvis = 0,
    this.compositions = const [],
    this.maladies = const [],
    this.offresPharmacopees = const [],
  });

  bool get enStock =>
      offresPharmacopees.any((o) => o.disponible && o.quantiteStock > 0);

  double get prixMinimum {
    if (offresPharmacopees.isEmpty) return prixIndicatif;
    return offresPharmacopees
        .map((o) => o.prix)
        .reduce((a, b) => a < b ? a : b);
  }

  ProduitSommaireModel toSommaire() {
    return ProduitSommaireModel(
      id: id,
      nom: nom,
      description: description,
      prixIndicatif: prixIndicatif,
      photoUrl: photoUrl,
      forme: forme,
      categorieId: categorieId,
      categorieNom: categorieNom,
      plantesPrincipales: compositions.map((c) => c.nomScientifique).toList(),
      nombrePharmacopees: offresPharmacopees.length,
      disponibleEnPharmacie: enStock,
      noteMoyenne: noteMoyenne,
      nombreAvis: nombreAvis,
    );
  }

  factory PopulationProduitDetailModel.fromJson(Map<String, dynamic> json) {
    return PopulationProduitDetailModel(
      id: json['id'] as int? ?? 0,
      nom: json['nom'] as String? ?? '',
      description: json['description'] as String?,
      forme: json['forme'] as String?,
      compositionTexte: json['compositionTexte'] as String?,
      prixIndicatif: (json['prixIndicatif'] as num?)?.toDouble() ?? 0.0,
      photoUrl: json['photoUrl'] as String?,
      categorieId: json['categorieId'] as int?,
      categorieNom: json['categorieNom'] as String?,
      noteMoyenne: (json['noteMoyenne'] as num?)?.toDouble(),
      nombreAvis: json['nombreAvis'] as int? ?? 0,
      compositions: (json['compositions'] as List<dynamic>?)
              ?.map((e) => PopulationCompositionItemModel.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          [],
      maladies: (json['maladies'] as List<dynamic>?)
              ?.map((e) {
                if (e is Map<String, dynamic>) {
                  return e['nom']?.toString() ?? '';
                }
                return e.toString();
              })
              .where((s) => s.isNotEmpty)
              .toList() ??
          [],
      offresPharmacopees: (json['offresPharmacopees'] as List<dynamic>?)
              ?.map((e) => PopulationOffrePharmacopeeModel.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'description': description,
        'forme': forme,
        'compositionTexte': compositionTexte,
        'prixIndicatif': prixIndicatif,
        'photoUrl': photoUrl,
        'categorieId': categorieId,
        'categorieNom': categorieNom,
        'noteMoyenne': noteMoyenne,
        'nombreAvis': nombreAvis,
        'compositions': compositions.map((e) => e.toJson()).toList(),
        'maladies': maladies,
        'offresPharmacopees':
            offresPharmacopees.map((e) => e.toJson()).toList(),
      };
}
