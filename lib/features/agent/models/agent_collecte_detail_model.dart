import 'package:equatable/equatable.dart';

class AgentCollecteDetailModel extends Equatable {
  final int id;
  final String? dateCollecte;
  final String? description;
  final String statut;
  final String? photoUrl;
  final String? audioUrl;
  final String? dateSoumission;
  final String? motifRejet;

  // Agent
  final int? agentId;
  final String? agentMatricule;
  final String? agentNomComplet;

  // Source
  final int? sourceId;
  final String? sourceNomComplet;
  final String? sourceSpecialite;
  final String? sourceTelephone;

  // Localisation
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
    required this.id,
    this.dateCollecte,
    this.description,
    required this.statut,
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
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      dateCollecte: json['dateCollecte']?.toString(),
      description: json['description']?.toString(),
      statut: json['statut']?.toString() ?? 'BROUILLON',
      photoUrl: json['photoUrl']?.toString(),
      audioUrl: json['audioUrl']?.toString(),
      dateSoumission: json['dateSoumission']?.toString(),
      motifRejet: json['motifRejet']?.toString(),
      agentId: json['agentId'] is int ? json['agentId'] : int.tryParse(json['agentId']?.toString() ?? ''),
      agentMatricule: json['agentMatricule']?.toString(),
      agentNomComplet: json['agentNomComplet']?.toString(),
      sourceId: json['sourceId'] is int ? json['sourceId'] : int.tryParse(json['sourceId']?.toString() ?? ''),
      sourceNomComplet: json['sourceNomComplet']?.toString(),
      sourceSpecialite: json['sourceSpecialite']?.toString(),
      sourceTelephone: json['sourceTelephone']?.toString(),
      localisationId: json['localisationId'] is int ? json['localisationId'] : int.tryParse(json['localisationId']?.toString() ?? ''),
      region: json['region']?.toString(),
      cercle: json['cercle']?.toString(),
      commune: json['commune']?.toString(),
      localite: json['localite']?.toString(),
      latitude: json['latitude'] is num ? (json['latitude'] as num).toDouble() : double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: json['longitude'] is num ? (json['longitude'] as num).toDouble() : double.tryParse(json['longitude']?.toString() ?? ''),
      nombreVertus: json['nombreVertus'] is int ? json['nombreVertus'] : int.tryParse(json['nombreVertus']?.toString() ?? '0') ?? 0,
      modifiable: json['modifiable'] == true,
      soumissible: json['soumissible'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'dateCollecte': dateCollecte,
    'description': description,
    'statut': statut,
    'photoUrl': photoUrl,
    'audioUrl': audioUrl,
    'dateSoumission': dateSoumission,
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

  @override
  List<Object?> get props => [
    id,
    dateCollecte,
    description,
    statut,
    photoUrl,
    audioUrl,
    dateSoumission,
    motifRejet,
    agentId,
    agentMatricule,
    agentNomComplet,
    sourceId,
    sourceNomComplet,
    sourceSpecialite,
    sourceTelephone,
    localisationId,
    region,
    cercle,
    commune,
    localite,
    latitude,
    longitude,
    nombreVertus,
    modifiable,
    soumissible,
  ];
}

