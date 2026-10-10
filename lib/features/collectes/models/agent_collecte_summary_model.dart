import 'package:ladafura_frontend_flutter/shared/enums/statut_collecte.dart';

class AgentCollecteSummaryModel {
  final int? id;
  final DateTime? dateCollecte;
  final String? description;
  final StatutCollecte? statut;
  final String? photoUrl;
  final String? audioUrl;
  final DateTime? dateSoumission;
  final String? motifRejet;
  final String? nomSource;
  final String? localite;
  final String? cercle;
  final String? region;
  final int nombreVertus;
  final String? nomScientifiquePlante;

  const AgentCollecteSummaryModel({
    this.id,
    this.dateCollecte,
    this.description,
    this.statut,
    this.photoUrl,
    this.audioUrl,
    this.dateSoumission,
    this.motifRejet,
    this.nomSource,
    this.localite,
    this.cercle,
    this.region,
    this.nombreVertus = 0,
    this.nomScientifiquePlante,
  });

  factory AgentCollecteSummaryModel.fromJson(Map<String, dynamic> json) {
    return AgentCollecteSummaryModel(
      id: (json['id'] as num?)?.toInt(),
      dateCollecte: _parseDateTime(json['dateCollecte']),
      description: json['description'] as String?,
      statut: StatutCollecte.fromString(json['statut'] as String?),
      photoUrl: json['photoUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
      dateSoumission: _parseDateTime(json['dateSoumission']),
      motifRejet: json['motifRejet'] as String?,
      nomSource: json['nomSource'] as String?,
      localite: json['localite'] as String?,
      cercle: json['cercle'] as String?,
      region: json['region'] as String?,
      nombreVertus: (json['nombreVertus'] as num?)?.toInt() ?? 0,
      nomScientifiquePlante: json['nomScientifiquePlante'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateCollecte': dateCollecte?.toIso8601String(),
        'description': description,
        'statut': statut?.value,
        'photoUrl': photoUrl,
        'audioUrl': audioUrl,
        'dateSoumission': dateSoumission?.toIso8601String(),
        'motifRejet': motifRejet,
        'nomSource': nomSource,
        'localite': localite,
        'cercle': cercle,
        'region': region,
        'nombreVertus': nombreVertus,
        'nomScientifiquePlante': nomScientifiquePlante,
      };
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
