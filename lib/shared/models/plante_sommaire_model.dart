/// Résumé synthétique d'une plante médicinale validée dans le catalogue LADAFURA.
///
/// Conforme au DTO backend `PopulationPlanteSummaryResponse.java` (US-01 & US-02).
class PlanteSommaireModel {
  final int id;
  final String nomScientifique;
  final String? description;
  final String? photoUrl;
  final List<String> nomsVernaculaires;
  final List<String> maladies;
  final int nombreConnaissances;
  final int nombreEtudesScientifiques;

  const PlanteSommaireModel({
    required this.id,
    required this.nomScientifique,
    this.description,
    this.photoUrl,
    this.nomsVernaculaires = const [],
    this.maladies = const [],
    this.nombreConnaissances = 0,
    this.nombreEtudesScientifiques = 0,
  });

  /// Nom local ou vernaculaire principal (ex: "Kinkéliba") ou repli sur le nom scientifique.
  String get nomVernaculairePrincipal =>
      nomsVernaculaires.isNotEmpty ? nomsVernaculaires.first : nomScientifique;

  /// Indique si la plante dispose d'une photo officielle validée.
  bool get hasPhoto => photoUrl != null && photoUrl!.trim().isNotEmpty;

  /// Indique si des études scientifiques valident les vertus de cette plante.
  bool get hasEtudesScientifiques => nombreEtudesScientifiques > 0;

  /// Indique si des savoirs traditionnels de guérisseurs sont enregistrés.
  bool get hasSavoirsTraditionnels => nombreConnaissances > 0;

  PlanteSommaireModel copyWith({
    int? id,
    String? nomScientifique,
    String? description,
    String? photoUrl,
    List<String>? nomsVernaculaires,
    List<String>? maladies,
    int? nombreConnaissances,
    int? nombreEtudesScientifiques,
  }) {
    return PlanteSommaireModel(
      id: id ?? this.id,
      nomScientifique: nomScientifique ?? this.nomScientifique,
      description: description ?? this.description,
      photoUrl: photoUrl ?? this.photoUrl,
      nomsVernaculaires: nomsVernaculaires ?? this.nomsVernaculaires,
      maladies: maladies ?? this.maladies,
      nombreConnaissances: nombreConnaissances ?? this.nombreConnaissances,
      nombreEtudesScientifiques:
          nombreEtudesScientifiques ?? this.nombreEtudesScientifiques,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nomScientifique': nomScientifique,
        'description': description,
        'photoUrl': photoUrl,
        'nomsVernaculaires': nomsVernaculaires,
        'maladies': maladies,
        'nombreConnaissances': nombreConnaissances,
        'nombreEtudesScientifiques': nombreEtudesScientifiques,
      };

  factory PlanteSommaireModel.fromJson(Map<String, dynamic> json) {
    return PlanteSommaireModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nomScientifique: json['nomScientifique']?.toString() ?? '',
      description: json['description']?.toString(),
      photoUrl: json['photoUrl']?.toString(),
      nomsVernaculaires: json['nomsVernaculaires'] is List
          ? (json['nomsVernaculaires'] as List)
              .map((e) => e.toString())
              .toList()
          : const [],
      maladies: json['maladies'] is List
          ? (json['maladies'] as List).map((e) => e.toString()).toList()
          : const [],
      nombreConnaissances: (json['nombreConnaissances'] as num?)?.toInt() ?? 0,
      nombreEtudesScientifiques:
          (json['nombreEtudesScientifiques'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  String toString() =>
      'PlanteSommaireModel(id: $id, nomScientifique: $nomScientifique, nomVernaculaire: $nomVernaculairePrincipal)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlanteSommaireModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nomScientifique == other.nomScientifique;

  @override
  int get hashCode => id.hashCode ^ nomScientifique.hashCode;
}
