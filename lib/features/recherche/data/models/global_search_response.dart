import '../../../../core/services/location_service.dart';

/// Modèle de résultat consolidé de la recherche universelle LADAFURA.
///
/// Conforme au DTO backend `PopulationGlobalSearchResponse.java`.
class GlobalSearchResponse {
  final String query;
  final int totalResultats;
  final List<PharmacopeeSearchItem> pharmacopees;
  final List<PlanteSearchItem> plantes;
  final List<VernaculaireSearchItem> nomsVernaculaires;
  final List<MaladieSearchItem> maladies;
  final List<ProduitSearchItem> produits;

  const GlobalSearchResponse({
    required this.query,
    this.totalResultats = 0,
    this.pharmacopees = const [],
    this.plantes = const [],
    this.nomsVernaculaires = const [],
    this.maladies = const [],
    this.produits = const [],
  });

  factory GlobalSearchResponse.fromJson(Map<String, dynamic> json) {
    return GlobalSearchResponse(
      query: json['query']?.toString() ?? '',
      totalResultats: (json['totalResultats'] as num?)?.toInt() ?? 0,
      pharmacopees: (json['pharmacopees'] as List<dynamic>?)
              ?.map((e) =>
                  PharmacopeeSearchItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      plantes: (json['plantes'] as List<dynamic>?)
              ?.map((e) => PlanteSearchItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      nomsVernaculaires: (json['nomsVernaculaires'] as List<dynamic>?)
              ?.map((e) =>
                  VernaculaireSearchItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      maladies: (json['maladies'] as List<dynamic>?)
              ?.map(
                  (e) => MaladieSearchItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      produits: (json['produits'] as List<dynamic>?)
              ?.map(
                  (e) => ProduitSearchItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  bool get isEmpty =>
      pharmacopees.isEmpty &&
      plantes.isEmpty &&
      maladies.isEmpty &&
      produits.isEmpty &&
      nomsVernaculaires.isEmpty;

  bool get isNotEmpty => !isEmpty;
}

/// Élément résultat de recherche pour une pharmacopée (Résultat Principal).
class PharmacopeeSearchItem {
  final int id;
  final String nom;
  final String? description;
  final String? telephone;
  final String? region;
  final String? cercle;
  final String? commune;
  final String? localite;
  final double? latitude;
  final double? longitude;
  final double noteMoyenne;
  final int nombreAvis;
  final String? photoUrl;
  final String? motifCorrespondance;
  final List<String> produitsDisponibles;

  const PharmacopeeSearchItem({
    required this.id,
    required this.nom,
    this.description,
    this.telephone,
    this.region,
    this.cercle,
    this.commune,
    this.localite,
    this.latitude,
    this.longitude,
    this.noteMoyenne = 4.5,
    this.nombreAvis = 0,
    this.photoUrl,
    this.motifCorrespondance,
    this.produitsDisponibles = const [],
  });

  /// Chaîne d'adresse lisible (ex: "Commune V, Bamako").
  String get adresseComplete {
    final parts = [localite, commune, cercle, region]
        .where((p) => p != null && p.trim().isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'Mali';
    if (parts.length > 2) return '${parts[0]}, ${parts[1]}';
    return parts.join(', ');
  }

  /// Distance formatée par rapport à une position géographique.
  String distanceFormatee(GeoCoordinates? userCoords) {
    if (userCoords == null || latitude == null || longitude == null) {
      return 'Mali';
    }
    final km = LocationService.calculateDistanceInKm(
      userCoords.latitude,
      userCoords.longitude,
      latitude!,
      longitude!,
    );
    if (km < 1.0) {
      return 'à ${(km * 1000).round()} m';
    }
    return 'à ${km.toStringAsFixed(1)} km';
  }

  /// Distance numérique en kilomètres pour le tri par proximité géographique.
  double distanceToKm(GeoCoordinates? userCoords) {
    if (userCoords == null || latitude == null || longitude == null) {
      return 999999.0;
    }
    return LocationService.calculateDistanceInKm(
      userCoords.latitude,
      userCoords.longitude,
      latitude!,
      longitude!,
    );
  }

  factory PharmacopeeSearchItem.fromJson(Map<String, dynamic> json) {
    return PharmacopeeSearchItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nom: json['nom']?.toString() ?? 'Pharmacie Traditionnelle',
      description: json['description']?.toString(),
      telephone: json['telephone']?.toString(),
      region: json['region']?.toString(),
      cercle: json['cercle']?.toString(),
      commune: json['commune']?.toString(),
      localite: json['localite']?.toString(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      noteMoyenne: (json['noteMoyenne'] as num?)?.toDouble() ?? 4.5,
      nombreAvis: (json['nombreAvis'] as num?)?.toInt() ?? 0,
      photoUrl: json['photoUrl']?.toString(),
      motifCorrespondance: json['motifCorrespondance']?.toString(),
      produitsDisponibles: (json['produitsDisponibles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}

/// Élément résultat de recherche pour une plante médicinale.
class PlanteSearchItem {
  final int id;
  final String nomScientifique;
  final String? description;
  final String? photoUrl;
  final List<String> nomsVernaculaires;

  const PlanteSearchItem({
    required this.id,
    required this.nomScientifique,
    this.description,
    this.photoUrl,
    this.nomsVernaculaires = const [],
  });

  factory PlanteSearchItem.fromJson(Map<String, dynamic> json) {
    final rawNoms = json['nomsVernaculaires'];
    List<String> parsedNoms = const [];
    if (rawNoms is List) {
      parsedNoms = rawNoms
          .map((e) {
            if (e is Map) {
              final nom = e['nom']?.toString() ?? '';
              final langue = e['langue']?.toString() ?? '';
              return langue.isNotEmpty ? '$nom ($langue)' : nom;
            }
            return e.toString();
          })
          .where((s) => s.trim().isNotEmpty)
          .toList();
    }

    return PlanteSearchItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nomScientifique: json['nomScientifique']?.toString() ?? '',
      description: json['description']?.toString(),
      photoUrl: json['photoUrl']?.toString(),
      nomsVernaculaires: parsedNoms,
    );
  }
}

/// Élément résultat de recherche pour un nom vernaculaire dans une langue locale.
class VernaculaireSearchItem {
  final int id;
  final String nom;
  final String langue;
  final int? planteId;
  final String? nomScientifiquePlante;

  const VernaculaireSearchItem({
    required this.id,
    required this.nom,
    required this.langue,
    this.planteId,
    this.nomScientifiquePlante,
  });

  factory VernaculaireSearchItem.fromJson(Map<String, dynamic> json) {
    return VernaculaireSearchItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nom: json['nom']?.toString() ?? '',
      langue: json['langue']?.toString() ?? 'Bambara',
      planteId: (json['planteId'] as num?)?.toInt(),
      nomScientifiquePlante: json['nomScientifiquePlante']?.toString(),
    );
  }
}

/// Élément résultat de recherche pour une maladie ou pathologie.
class MaladieSearchItem {
  final int id;
  final String nom;
  final String? description;
  final int nombrePlantesAssociees;

  const MaladieSearchItem({
    required this.id,
    required this.nom,
    this.description,
    this.nombrePlantesAssociees = 0,
  });

  factory MaladieSearchItem.fromJson(Map<String, dynamic> json) {
    return MaladieSearchItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nom: json['nom']?.toString() ?? '',
      description: json['description']?.toString(),
      nombrePlantesAssociees:
          (json['nombrePlantesAssociees'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Élément résultat de recherche pour un remède ou produit de pharmacopée.
class ProduitSearchItem {
  final int id;
  final String nom;
  final String? description;
  final String? forme;
  final double prix;
  final String? photoUrl;
  final String? categorie;

  const ProduitSearchItem({
    required this.id,
    required this.nom,
    this.description,
    this.forme,
    this.prix = 0.0,
    this.photoUrl,
    this.categorie,
  });

  String get prixFormate {
    final intValue = prix.round();
    final formatted = intValue.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
    return '$formatted FCFA';
  }

  factory ProduitSearchItem.fromJson(Map<String, dynamic> json) {
    return ProduitSearchItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nom: json['nom']?.toString() ?? '',
      description: json['description']?.toString(),
      forme: json['forme']?.toString(),
      prix: (json['prix'] as num?)?.toDouble() ?? 0.0,
      photoUrl: json['photoUrl']?.toString(),
      categorie: json['categorie']?.toString(),
    );
  }
}
