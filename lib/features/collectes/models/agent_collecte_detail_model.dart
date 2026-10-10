import 'package:ladafura_frontend_flutter/shared/enums/statut_collecte.dart';

class AgentCollecteDetailModel {
  final int? id;
  final DateTime? dateCollecte;
  final String? description;
  final StatutCollecte? statut;
  final String? photoUrl;
  final String? audioUrl;
  final DateTime? dateSoumission;
  final String? motifRejet;
  final int? agentId;
  final String? agentMatricule;
  final String? agentNomComplet;
  final int? sourceId;
  final String? sourceNomComplet;
  final String? sourceSpecialite;
  final String? sourceTelephone;
  final int? localisationId;
  final String? region;
  final String? cercle;
  final String? commune;
  final String? localite;
  final double? latitude;
  final double? longitude;
  final int nombreVertus;
  final bool modifiable;
  final bool soumissible;

  const AgentCollecteDetailModel({
    this.id,
    this.dateCollecte,
    this.description,
    this.statut,
    this.photoUrl,
    this.audioUrl,
    this.dateSoumission,
    this.motifRejet,
    this.agentId,
    this.agentMatricule,
    this.agentNomComplet,
    this.sourceId,
    this.sourceNomComplet,
    this.sourceSpecialite,
    this.sourceTelephone,
    this.localisationId,
    this.region,
    this.cercle,
    this.commune,
    this.localite,
    this.latitude,
    this.longitude,
    this.nombreVertus = 0,
    this.modifiable = false,
    this.soumissible = false,
  });

  factory AgentCollecteDetailModel.fromJson(Map<String, dynamic> json) {
    return AgentCollecteDetailModel(
      id: (json['id'] as num?)?.toInt(),
      dateCollecte: _parseDateTime(json['dateCollecte']),
      description: json['description'] as String?,
      statut: StatutCollecte.fromString(json['statut'] as String?),
      photoUrl: json['photoUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
      dateSoumission: _parseDateTime(json['dateSoumission']),
      motifRejet: json['motifRejet'] as String?,
      agentId: (json['agentId'] as num?)?.toInt(),
      agentMatricule: json['agentMatricule'] as String?,
      agentNomComplet: json['agentNomComplet'] as String?,
      sourceId: (json['sourceId'] as num?)?.toInt(),
      sourceNomComplet: json['sourceNomComplet'] as String?,
      sourceSpecialite: json['sourceSpecialite'] as String?,
      sourceTelephone: json['sourceTelephone'] as String?,
      localisationId: (json['localisationId'] as num?)?.toInt(),
      region: json['region'] as String?,
      cercle: json['cercle'] as String?,
      commune: json['commune'] as String?,
      localite: json['localite'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      nombreVertus: (json['nombreVertus'] as num?)?.toInt() ?? 0,
      modifiable: json['modifiable'] as bool? ?? false,
      soumissible: json['soumissible'] as bool? ?? false,
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
        'agentId': agentId,
        'agentMatricule': agentMatricule,
        'agentNomComplet': agentNomComplet,
        'sourceId': sourceId,
        'sourceNomComplet': sourceNomComplet,
        'sourceSpecialite': sourceSpecialite,
        'sourceTelephone': sourceTelephone,
        'localisationId': localisationId,
        'region': region,
        'cercle': cercle,
        'commune': commune,
        'localite': localite,
        'latitude': latitude,
        'longitude': longitude,
        'nombreVertus': nombreVertus,
        'modifiable': modifiable,
        'soumissible': soumissible,
      };
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
