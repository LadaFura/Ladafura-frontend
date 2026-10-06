import '../../../../core/services/location_service.dart';

/// Mode de retrait proposé par la pharmacopée (Livraison ou Pickup).
/// Conforme au DTO backend `PopulationPharmacopeeModeRetraitDto.java`.
class PharmacopeeModeRetraitModel {
  final int id;
  final String type; // "LIVRAISON" ou "PICKUP"
  final bool actif;
  final double frais;

  const PharmacopeeModeRetraitModel({
    required this.id,
    required this.type,
    required this.actif,
    required this.frais,
  });

  bool get isLivraison => type.toUpperCase() == 'LIVRAISON';
  bool get isPickup => type.toUpperCase() == 'PICKUP';

  String get typeLibelle => isLivraison ? 'Livraison' : 'Retrait sur place';

  String get fraisFormate {
    if (frais <= 0) return 'Gratuit';
    final intValue = frais.round();
    final formatted = intValue.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
    return '$formatted FCFA';
  }

  factory PharmacopeeModeRetraitModel.fromJson(Map<String, dynamic> json) {
    return PharmacopeeModeRetraitModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: json['type']?.toString() ?? 'PICKUP',
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

/// Localisation géographique complète de la pharmacopée.
/// Conforme au DTO backend `PopulationPharmacopeeLocalisationDto.java`.
class PharmacopeeLocalisationModel {
  final String? region;
  final String? cercle;
  final String? commune;
  final String? localite;
  final double? latitude;
  final double? longitude;

  const PharmacopeeLocalisationModel({
    this.region,
    this.cercle,
    this.commune,
    this.localite,
    this.latitude,
    this.longitude,
  });

  String get adresseComplete {
    final parts = [localite, commune, cercle, region]
        .where((p) => p != null && p.trim().isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'Mali';
    return parts.join(', ');
  }

  String get villeEtCommune {
    final parts = [commune, region ?? cercle]
        .where((p) => p != null && p.trim().isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'Mali';
    return parts.join(', ');
  }

  factory PharmacopeeLocalisationModel.fromJson(Map<String, dynamic> json) {
    return PharmacopeeLocalisationModel(
      region: json['region']?.toString(),
      cercle: json['cercle']?.toString(),
      commune: json['commune']?.toString(),
      localite: json['localite']?.toString(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'region': region,
        'cercle': cercle,
        'commune': commune,
        'localite': localite,
        'latitude': latitude,
        'longitude': longitude,
      };
}

/// Modèle complet de la fiche détaillée d'une pharmacopée agréée.
/// Conforme au DTO backend `PopulationPharmacopeeDetailResponse.java`.
class PharmacopeeDetailModel {
  final int id;
  final String nom;
  final String? description;
  final String? telephone;
  final String? email;
  final String? photoUrl;
  final PharmacopeeLocalisationModel? localisation;
  final List<PharmacopeeModeRetraitModel> modesRetrait;
  final int nombreProduits;
  final double noteMoyenne;
  final int nombreAvis;

  const PharmacopeeDetailModel({
    required this.id,
    required this.nom,
    this.description,
    this.telephone,
    this.email,
    this.photoUrl,
    this.localisation,
    this.modesRetrait = const [],
    this.nombreProduits = 0,
    this.noteMoyenne = 0.0,
    this.nombreAvis = 0,
  });

  bool get proposeLivraison =>
      modesRetrait.any((m) => m.isLivraison && m.actif);

  bool get proposePickup =>
      modesRetrait.any((m) => m.isPickup && m.actif);

  double? get fraisLivraison {
    final mode = modesRetrait.where((m) => m.isLivraison && m.actif).firstOrNull;
    return mode?.frais;
  }

  double? get latitude => localisation?.latitude;
  double? get longitude => localisation?.longitude;

  /// Calcule la distance par rapport aux coordonnées GPS de l'utilisateur.
  double? distanceToKm(GeoCoordinates? userCoords) {
    if (userCoords == null || latitude == null || longitude == null) {
      return null;
    }
    return LocationService.calculateDistanceInKm(
      userCoords.latitude,
      userCoords.longitude,
      latitude!,
      longitude!,
    );
  }

  /// Chaîne formatée de la distance (ex: "À 2.4 km de vous" ou "À 850 m de vous").
  String? distanceFormatee(GeoCoordinates? userCoords) {
    final km = distanceToKm(userCoords);
    if (km == null) return null;
    if (km < 1.0) {
      return 'À ${(km * 1000).round()} m de vous';
    }
    return 'À ${km.toStringAsFixed(1)} km de vous';
  }

  factory PharmacopeeDetailModel.fromJson(Map<String, dynamic> json) {
    final modesJson = json['modesRetrait'] as List<dynamic>?;
    final modes = modesJson != null
        ? modesJson
            .map((e) => PharmacopeeModeRetraitModel.fromJson(e as Map<String, dynamic>))
            .toList()
        : <PharmacopeeModeRetraitModel>[];

    final locJson = json['localisation'] as Map<String, dynamic>?;
    final loc = locJson != null
        ? PharmacopeeLocalisationModel.fromJson(locJson)
        : (json['latitude'] != null && json['longitude'] != null
            ? PharmacopeeLocalisationModel(
                region: json['region']?.toString(),
                cercle: json['cercle']?.toString(),
                commune: json['commune']?.toString(),
                localite: json['localite']?.toString(),
                latitude: (json['latitude'] as num?)?.toDouble(),
                longitude: (json['longitude'] as num?)?.toDouble(),
              )
            : null);

    return PharmacopeeDetailModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nom: json['nom']?.toString() ?? 'Pharmacopée Traditionnelle',
      description: json['description']?.toString(),
      telephone: json['telephone']?.toString(),
      email: json['email']?.toString(),
      photoUrl: json['photoUrl']?.toString(),
      localisation: loc,
      modesRetrait: modes,
      nombreProduits: (json['nombreProduits'] as num?)?.toInt() ?? 0,
      noteMoyenne: (json['noteMoyenne'] as num?)?.toDouble() ?? 0.0,
      nombreAvis: (json['nombreAvis'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'description': description,
        'telephone': telephone,
        'email': email,
        'photoUrl': photoUrl,
        'localisation': localisation?.toJson(),
        'modesRetrait': modesRetrait.map((m) => m.toJson()).toList(),
        'nombreProduits': nombreProduits,
        'noteMoyenne': noteMoyenne,
        'nombreAvis': nombreAvis,
      };
}

