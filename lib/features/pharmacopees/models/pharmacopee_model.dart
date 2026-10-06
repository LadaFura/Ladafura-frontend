import '../../../../core/services/location_service.dart';

/// Modèle synthétique d'une pharmacopée traditionnelle agréée LADAFURA.
///
/// Conforme au DTO backend `PopulationPharmacopeeSummaryResponse.java`.
class PharmacopeeModel {
  final int id;
  final String nom;
  final String? description;
  final String? telephone;
  final String? region;
  final String? cercle;
  final String? commune;
  final String? localite;
  final double latitude;
  final double longitude;
  final bool proposeLivraison;
  final bool proposePickup;
  final int nombreProduits;
  final double noteMoyenne;
  final int nombreAvis;
  final String? photoUrl;
  final String? motifCorrespondance;
  final List<String> produitsDisponibles;

  const PharmacopeeModel({
    required this.id,
    required this.nom,
    this.description,
    this.telephone,
    this.region,
    this.cercle,
    this.commune,
    this.localite,
    required this.latitude,
    required this.longitude,
    this.proposeLivraison = true,
    this.proposePickup = true,
    this.nombreProduits = 0,
    this.noteMoyenne = 4.5,
    this.nombreAvis = 0,
    this.photoUrl,
    this.motifCorrespondance,
    this.produitsDisponibles = const [],
  });

  /// Adresse lisible complète (ex: "Badalabougou, Bamako" ou "Siby, Kati, Koulikoro").
  String get adresseComplete {
    final parts = [localite, commune, cercle, region]
        .where((p) => p != null && p.trim().isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'Bamako, Mali';
    if (parts.length > 2) return '${parts[0]}, ${parts[1]}';
    return parts.join(', ');
  }

  /// Calcule la distance en kilomètres par rapport aux coordonnées de l'utilisateur.
  double distanceToKm(GeoCoordinates? userCoords) {
    if (userCoords == null) return 1.5;
    return LocationService.calculateDistanceInKm(
      userCoords.latitude,
      userCoords.longitude,
      latitude,
      longitude,
    );
  }

  /// Chaîne formatée de la distance (ex: "à 1.2 km" ou "à 850 m").
  String distanceFormatee(GeoCoordinates? userCoords) {
    final km = distanceToKm(userCoords);
    if (km < 1.0) {
      return 'à ${(km * 1000).round()} m';
    }
    return 'à ${km.toStringAsFixed(1)} km';
  }

  factory PharmacopeeModel.fromJson(Map<String, dynamic> json) {
    return PharmacopeeModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nom: json['nom']?.toString() ?? 'Pharmacie Traditionnelle',
      description: json['description']?.toString(),
      telephone: json['telephone']?.toString(),
      region: json['region']?.toString(),
      cercle: json['cercle']?.toString(),
      commune: json['commune']?.toString(),
      localite: json['localite']?.toString(),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 12.6392,
      longitude: (json['longitude'] as num?)?.toDouble() ?? -8.0029,
      proposeLivraison: json['proposeLivraison'] as bool? ?? true,
      proposePickup: json['proposePickup'] as bool? ?? true,
      nombreProduits: (json['nombreProduits'] as num?)?.toInt() ?? 0,
      noteMoyenne: (json['noteMoyenne'] as num?)?.toDouble() ?? 4.5,
      nombreAvis: (json['nombreAvis'] as num?)?.toInt() ?? 100,
      photoUrl: json['photoUrl']?.toString(),
      motifCorrespondance: json['motifCorrespondance']?.toString(),
      produitsDisponibles: (json['produitsDisponibles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  PharmacopeeModel copyWith({
    int? id,
    String? nom,
    String? description,
    String? telephone,
    String? region,
    String? cercle,
    String? commune,
    String? localite,
    double? latitude,
    double? longitude,
    bool? proposeLivraison,
    bool? proposePickup,
    int? nombreProduits,
    double? noteMoyenne,
    int? nombreAvis,
    String? photoUrl,
    String? motifCorrespondance,
    List<String>? produitsDisponibles,
  }) {
    return PharmacopeeModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      telephone: telephone ?? this.telephone,
      region: region ?? this.region,
      cercle: cercle ?? this.cercle,
      commune: commune ?? this.commune,
      localite: localite ?? this.localite,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      proposeLivraison: proposeLivraison ?? this.proposeLivraison,
      proposePickup: proposePickup ?? this.proposePickup,
      nombreProduits: nombreProduits ?? this.nombreProduits,
      noteMoyenne: noteMoyenne ?? this.noteMoyenne,
      nombreAvis: nombreAvis ?? this.nombreAvis,
      photoUrl: photoUrl ?? this.photoUrl,
      motifCorrespondance: motifCorrespondance ?? this.motifCorrespondance,
      produitsDisponibles: produitsDisponibles ?? this.produitsDisponibles,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'description': description,
        'telephone': telephone,
        'region': region,
        'cercle': cercle,
        'commune': commune,
        'localite': localite,
        'latitude': latitude,
        'longitude': longitude,
        'proposeLivraison': proposeLivraison,
        'proposePickup': proposePickup,
        'nombreProduits': nombreProduits,
        'noteMoyenne': noteMoyenne,
        'nombreAvis': nombreAvis,
        'photoUrl': photoUrl,
        'motifCorrespondance': motifCorrespondance,
        'produitsDisponibles': produitsDisponibles,
      };
}
