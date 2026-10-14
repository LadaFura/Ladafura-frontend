import 'package:equatable/equatable.dart';

class AgentCollecteRecapitulatifModel extends Equatable {
  final int collecteId;
  final String? dateCollecte;
  final String? description;
  final String statut;
  final String? agentNomComplet;

  // Plante
  final bool planteAssociee;
  final int? planteId;
  final String? planteNomScientifique;
  final List<String> nomsVernaculaires;

  // Connaissances
  final bool connaissanceRenseignee;
  final int nombreConnaissances;
  final List<String> usagesRapportes;
  final List<String> partiesUtilisees;
  final List<String> modesPreparation;
  final List<String> precautions;
  final List<String> maladiesAssociees;

  // Source
  final bool sourceRattachee;
  final int? sourceId;
  final String? sourceNomComplet;
  final String? sourceSpecialite;

  // Médias
  final bool mediasPresents;
  final String? photoUrl;
  final String? audioUrl;
  final bool photoPresente;
  final bool audioPresent;

  // Localisation
  final bool localisationRenseignee;
  final String? region;
  final String? cercle;
  final String? commune;
  final String? localite;
  final double? latitude;
  final double? longitude;
  final String? adresseFormatee;

  // Checklist
  final bool conformePourSoumission;
  final List<String> erreursBloquantes;
  final List<String> pointsDeVigilance;
  final String? prochaineEtape;

  const AgentCollecteRecapitulatifModel({
    required this.collecteId,
    this.dateCollecte,
    this.description,
    required this.statut,
    this.agentNomComplet,
    this.planteAssociee = false,
    this.planteId,
    this.planteNomScientifique,
    this.nomsVernaculaires = const [],
    this.connaissanceRenseignee = false,
    this.nombreConnaissances = 0,
    this.usagesRapportes = const [],
    this.partiesUtilisees = const [],
    this.modesPreparation = const [],
    this.precautions = const [],
    this.maladiesAssociees = const [],
    this.sourceRattachee = false,
    this.sourceId,
    this.sourceNomComplet,
    this.sourceSpecialite,
    this.mediasPresents = false,
    this.photoUrl,
    this.audioUrl,
    this.photoPresente = false,
    this.audioPresent = false,
    this.localisationRenseignee = false,
    this.region,
    this.cercle,
    this.commune,
    this.localite,
    this.latitude,
    this.longitude,
    this.adresseFormatee,
    this.conformePourSoumission = false,
    this.erreursBloquantes = const [],
    this.pointsDeVigilance = const [],
    this.prochaineEtape,
  });

  factory AgentCollecteRecapitulatifModel.fromJson(Map<String, dynamic> json) {
    List<String> toStrList(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString()).toList();
      }
      return [];
    }

    return AgentCollecteRecapitulatifModel(
      collecteId: json['collecteId'] is int
          ? json['collecteId']
          : int.tryParse(json['collecteId']?.toString() ?? '0') ?? 0,
      dateCollecte: json['dateCollecte']?.toString(),
      description: json['description']?.toString(),
      statut: json['statut']?.toString() ?? 'BROUILLON',
      agentNomComplet: json['agentNomComplet']?.toString(),
      planteAssociee: json['planteAssociee'] == true,
      planteId: json['planteId'] is int ? json['planteId'] : int.tryParse(json['planteId']?.toString() ?? ''),
      planteNomScientifique: json['planteNomScientifique']?.toString(),
      nomsVernaculaires: toStrList(json['nomsVernaculaires']),
      connaissanceRenseignee: json['connaissanceRenseignee'] == true,
      nombreConnaissances: json['nombreConnaissances'] is int ? json['nombreConnaissances'] : 0,
      usagesRapportes: toStrList(json['usagesRapportes']),
      partiesUtilisees: toStrList(json['partiesUtilisees']),
      modesPreparation: toStrList(json['modesPreparation']),
      precautions: toStrList(json['precautions']),
      maladiesAssociees: toStrList(json['maladiesAssociees']),
      sourceRattachee: json['sourceRattachee'] == true,
      sourceId: json['sourceId'] is int ? json['sourceId'] : int.tryParse(json['sourceId']?.toString() ?? ''),
      sourceNomComplet: json['sourceNomComplet']?.toString(),
      sourceSpecialite: json['sourceSpecialite']?.toString(),
      mediasPresents: json['mediasPresents'] == true,
      photoUrl: json['photoUrl']?.toString(),
      audioUrl: json['audioUrl']?.toString(),
      photoPresente: json['photoPresente'] == true,
      audioPresent: json['audioPresent'] == true,
      localisationRenseignee: json['localisationRenseignee'] == true,
      region: json['region']?.toString(),
      cercle: json['cercle']?.toString(),
      commune: json['commune']?.toString(),
      localite: json['localite']?.toString(),
      latitude: json['latitude'] is num ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] is num ? (json['longitude'] as num).toDouble() : null,
      adresseFormatee: json['adresseFormatee']?.toString(),
      conformePourSoumission: json['conformePourSoumission'] == true,
      erreursBloquantes: toStrList(json['erreursBloquantes']),
      pointsDeVigilance: toStrList(json['pointsDeVigilance']),
      prochaineEtape: json['prochaineEtape']?.toString(),
    );
  }

  @override
  List<Object?> get props => [
    collecteId,
    statut,
    planteAssociee,
    connaissanceRenseignee,
    sourceRattachee,
    mediasPresents,
    localisationRenseignee,
    conformePourSoumission,
  ];
}

