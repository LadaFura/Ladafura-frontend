import 'package:ladafura_frontend_flutter/shared/enums/statut_collecte.dart';

/// Résumé d'une collecte renvoyé par `GET /api/v1/agent/collectes`.
///
/// Correspond au DTO backend `AgentCollecteSummaryResponse`.
class AgentCollecteSummaryResponse {
  final int id;
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

  const AgentCollecteSummaryResponse({
    required this.id,
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

  factory AgentCollecteSummaryResponse.fromJson(Map<String, dynamic> json) {
    return AgentCollecteSummaryResponse(
      id: (json['id'] as num?)?.toInt() ?? 0,
      dateCollecte: _parseDate(json['dateCollecte']),
      description: json['description']?.toString(),
      statut: StatutCollecte.fromString(json['statut']?.toString()),
      photoUrl: json['photoUrl']?.toString(),
      audioUrl: json['audioUrl']?.toString(),
      dateSoumission: _parseDate(json['dateSoumission']),
      motifRejet: json['motifRejet']?.toString(),
      nomSource: json['nomSource']?.toString(),
      localite: json['localite']?.toString(),
      cercle: json['cercle']?.toString(),
      region: json['region']?.toString(),
      nombreVertus: (json['nombreVertus'] as num?)?.toInt() ?? 0,
      nomScientifiquePlante: json['nomScientifiquePlante']?.toString(),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
