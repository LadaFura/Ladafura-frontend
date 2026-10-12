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
      id: json['id'],
      dateCollecte: DateTime.parse(json['dateCollecte']),
      description: json['description'],
      statut: json['statut'],
      photoUrl: json['photoUrl'],
      audioUrl: json['audioUrl'],
      dateSoumission: json['dateSoumission'] != null
          ? DateTime.parse(json['dateSoumission'])
          : null,
      motifRejet: json['motifRejet'],
      nomSource: json['nomSource'],
      localite: json['localite'],
      cercle: json['cercle'],
      region: json['region'],
      nombreVertus: json['nombreVertus'],
      nomScientifiquePlante: json['nomScientifiquePlante'],
    );
  }
}