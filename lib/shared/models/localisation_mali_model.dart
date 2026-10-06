/// Modèle transversal représentant une localisation administrative et géographique au Mali (US-16).
///
/// Conforme à l'entité JPA `com.pharmacopee.ladafura.Models.Localisation`
/// et aux DTOs `AgentLocalisationResponse` et `PharmacopeeLocalisationResponse`.
class LocalisationMaliModel {
  final int? id;
  final String region;
  final String cercle;
  final String commune;
  final String localite;
  final double? latitude;
  final double? longitude;

  const LocalisationMaliModel({
    this.id,
    required this.region,
    required this.cercle,
    required this.commune,
    required this.localite,
    this.latitude,
    this.longitude,
  });

  /// Liste officielle des grandes régions administratives du Mali.
  static const List<String> regionsMali = [
    'District de Bamako',
    'Kayes',
    'Koulikoro',
    'Sikasso',
    'Ségou',
    'Mopti',
    'Tombouctou',
    'Gao',
    'Kidal',
    'Taoudénit',
    'Ménaka',
  ];

  /// Libellé administratif complet pour affichage sur les fiches de collecte ou de pharmacopées.
  String get libelleComplet => '$localite, $commune, $cercle ($region)';

  /// Indique si des coordonnées GPS précises sont associées à cette localisation.
  bool get hasGps => latitude != null && longitude != null;

  /// Coordonnées GPS formatées en texte lisible.
  String get gpsFormatted {
    if (!hasGps) return 'Non géolocalisé';
    final latDir = latitude! >= 0 ? 'N' : 'S';
    final lngDir = longitude! >= 0 ? 'E' : 'W';
    return '${latitude!.abs().toStringAsFixed(4)}° $latDir, ${longitude!.abs().toStringAsFixed(4)}° $lngDir';
  }

  LocalisationMaliModel copyWith({
    int? id,
    String? region,
    String? cercle,
    String? commune,
    String? localite,
    double? latitude,
    double? longitude,
  }) {
    return LocalisationMaliModel(
      id: id ?? this.id,
      region: region ?? this.region,
      cercle: cercle ?? this.cercle,
      commune: commune ?? this.commune,
      localite: localite ?? this.localite,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'region': region,
        'cercle': cercle,
        'commune': commune,
        'localite': localite,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory LocalisationMaliModel.fromJson(Map<String, dynamic> json) {
    return LocalisationMaliModel(
      id: (json['id'] as num?)?.toInt(),
      region: json['region']?.toString() ?? '',
      cercle: json['cercle']?.toString() ?? '',
      commune: json['commune']?.toString() ?? '',
      localite: json['localite']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  @override
  String toString() =>
      'LocalisationMaliModel($libelleComplet, GPS: $gpsFormatted)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalisationMaliModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          region == other.region &&
          cercle == other.cercle &&
          commune == other.commune &&
          localite == other.localite;

  @override
  int get hashCode =>
      id.hashCode ^
      region.hashCode ^
      cercle.hashCode ^
      commune.hashCode ^
      localite.hashCode;
}
