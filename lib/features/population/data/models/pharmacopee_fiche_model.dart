import 'package:ladafura_frontend_flutter/features/population/data/models/produit_model.dart';

/// Point d'intérêt cartographique représentant une officine agréée sur la carte (US-05, EF23).
class PopulationCartePharmacopeeModel {
  final int pharmacopeeId;
  final String nom;
  final String? description;
  final String? telephone;
  final String? region;
  final String? cercle;
  final String? commune;
  final String? localite;
  final double? latitude;
  final double? longitude;
  final double? distanceKm;
  final bool proposeLivraison;
  final bool proposePickup;
  final int nombreProduits;
  final double? noteMoyenne;
  final int nombreAvis;

  const PopulationCartePharmacopeeModel({
    required this.pharmacopeeId,
    required this.nom,
    this.description,
    this.telephone,
    this.region,
    this.cercle,
    this.commune,
    this.localite,
    this.latitude,
    this.longitude,
    this.distanceKm,
    this.proposeLivraison = true,
    this.proposePickup = true,
    this.nombreProduits = 0,
    this.noteMoyenne,
    this.nombreAvis = 0,
  });

  String get adresseComplete {
    final parts = [localite, commune, cercle, region]
        .where((s) => s != null && s.isNotEmpty)
        .toList();
    return parts.isNotEmpty ? parts.join(', ') : 'Adresse non renseignée';
  }

  factory PopulationCartePharmacopeeModel.fromJson(Map<String, dynamic> json) {
    return PopulationCartePharmacopeeModel(
      pharmacopeeId: json['pharmacopeeId'] as int? ?? 0,
      nom: json['nom'] as String? ?? '',
      description: json['description'] as String?,
      telephone: json['telephone'] as String?,
      region: json['region'] as String?,
      cercle: json['cercle'] as String?,
      commune: json['commune'] as String?,
      localite: json['localite'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      proposeLivraison: json['proposeLivraison'] as bool? ?? false,
      proposePickup: json['proposePickup'] as bool? ?? true,
      nombreProduits: (json['nombreProduits'] as num?)?.toInt() ?? 0,
      noteMoyenne: (json['noteMoyenne'] as num?)?.toDouble(),
      nombreAvis: (json['nombreAvis'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'pharmacopeeId': pharmacopeeId,
        'nom': nom,
        'description': description,
        'telephone': telephone,
        'region': region,
        'cercle': cercle,
        'commune': commune,
        'localite': localite,
        'latitude': latitude,
        'longitude': longitude,
        'distanceKm': distanceKm,
        'proposeLivraison': proposeLivraison,
        'proposePickup': proposePickup,
        'nombreProduits': nombreProduits,
        'noteMoyenne': noteMoyenne,
        'nombreAvis': nombreAvis,
      };
}

/// Fiche détaillée complète d'une officine de pharmacopée.
class PopulationPharmacopeeFicheModel {
  final int pharmacopeeId;
  final String nom;
  final String? description;
  final String? telephone;
  final String? email;
  final String? adresse;
  final double? latitude;
  final double? longitude;
  final double? distanceKm;
  final List<PopulationModeRetraitModel> modesRetrait;
  final int nombreProduits;
  final double? noteMoyenne;
  final int nombreAvis;

  const PopulationPharmacopeeFicheModel({
    required this.pharmacopeeId,
    required this.nom,
    this.description,
    this.telephone,
    this.email,
    this.adresse,
    this.latitude,
    this.longitude,
    this.distanceKm,
    this.modesRetrait = const [],
    this.nombreProduits = 0,
    this.noteMoyenne,
    this.nombreAvis = 0,
  });

  factory PopulationPharmacopeeFicheModel.fromJson(Map<String, dynamic> json) {
    final loc = json['localisation'] as Map<String, dynamic>?;
    return PopulationPharmacopeeFicheModel(
      pharmacopeeId: json['pharmacopeeId'] as int? ?? 0,
      nom: json['nom'] as String? ?? '',
      description: json['description'] as String?,
      telephone: json['telephone'] as String?,
      email: json['email'] as String?,
      adresse: loc != null
          ? [loc['localite'], loc['commune'], loc['region']]
              .where((e) => e != null && e.toString().isNotEmpty)
              .join(', ')
          : json['adresse'] as String?,
      latitude: loc != null
          ? (loc['latitude'] as num?)?.toDouble()
          : (json['latitude'] as num?)?.toDouble(),
      longitude: loc != null
          ? (loc['longitude'] as num?)?.toDouble()
          : (json['longitude'] as num?)?.toDouble(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      modesRetrait: (json['modesRetrait'] as List<dynamic>?)
              ?.map((e) => PopulationModeRetraitModel.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          [],
      nombreProduits: (json['nombreProduits'] as num?)?.toInt() ?? 0,
      noteMoyenne: (json['noteMoyenne'] as num?)?.toDouble(),
      nombreAvis: (json['nombreAvis'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'pharmacopeeId': pharmacopeeId,
        'nom': nom,
        'description': description,
        'telephone': telephone,
        'email': email,
        'adresse': adresse,
        'latitude': latitude,
        'longitude': longitude,
        'distanceKm': distanceKm,
        'modesRetrait': modesRetrait.map((e) => e.toJson()).toList(),
        'nombreProduits': nombreProduits,
        'noteMoyenne': noteMoyenne,
        'nombreAvis': nombreAvis,
      };
}
