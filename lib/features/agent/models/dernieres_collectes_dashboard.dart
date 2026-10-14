class DerniereCollecte {
  final int id;
  final DateTime dateCollecte;
  final String description;
  final String statut;
  final String? photoUrl;
  final String? audioUrl;
  final DateTime? dateSoumission;
  final String? motifRejet;
  final String nomSource;
  final String localite;
  final String cercle;
  final String region;
  final int nombreVertus;
  final String nomScientifiquePlante;

  DerniereCollecte({
    required this.id,
    required this.dateCollecte,
    required this.description,
    required this.statut,
    this.photoUrl,
    this.audioUrl,
    this.dateSoumission,
    this.motifRejet,
    required this.nomSource,
    required this.localite,
    required this.cercle,
    required this.region,
    required this.nombreVertus,
    required this.nomScientifiquePlante,
  });

  factory DerniereCollecte.fromJson(Map<String, dynamic> json) {
    return DerniereCollecte(
      id: (json['id'] as num?)?.toInt() ?? 0,
      dateCollecte: json['dateCollecte'] != null
          ? DateTime.tryParse(json['dateCollecte'].toString()) ?? DateTime.now()
          : DateTime.now(),
      description: json['description'] as String? ?? 'Aucune description',
      statut: json['statut'] as String? ?? 'BROUILLON',
      photoUrl: json['photoUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
      dateSoumission: json['dateSoumission'] != null
          ? DateTime.tryParse(json['dateSoumission'].toString())
          : null,
      motifRejet: json['motifRejet'] as String?,
      nomSource: json['nomSource'] as String? ?? 'Source non renseignée',
      localite: json['localite'] as String? ?? '',
      cercle: json['cercle'] as String? ?? '',
      region: json['region'] as String? ?? '',
      nombreVertus: (json['nombreVertus'] as num?)?.toInt() ?? 0,
      nomScientifiquePlante:
          json['nomScientifiquePlante'] as String? ?? 'Plante non spécifiée',
    );
  }
}