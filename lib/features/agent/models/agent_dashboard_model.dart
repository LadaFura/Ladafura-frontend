import 'package:equatable/equatable.dart';
import '../../collectes/models/agent_collecte_summary_response.dart';

class AgentDashboardModel extends Equatable {
  final AgentInfoModel? agent;
  final AgentStatsModel statistiques;
  final List<AgentCollecteSummaryResponse> dernieresCollectes;

  const AgentDashboardModel({
    this.agent,
    required this.statistiques,
    this.dernieresCollectes = const [],
  });

  factory AgentDashboardModel.fromJson(Map<String, dynamic> json) {
    return AgentDashboardModel(
      agent: json['agent'] != null ? AgentInfoModel.fromJson(json['agent']) : null,
      statistiques: json['statistiques'] != null
          ? AgentStatsModel.fromJson(json['statistiques'])
          : const AgentStatsModel(),
      dernieresCollectes: json['dernieresCollectes'] is List
          ? (json['dernieresCollectes'] as List)
              .map((e) => AgentCollecteSummaryResponse.fromJson(e))
              .toList()
          : const [],
    );
  }

  @override
  List<Object?> get props => [agent, statistiques, dernieresCollectes];
}

class AgentInfoModel extends Equatable {
  final int id;
  final String? nom;
  final String? prenom;
  final String? email;
  final String? telephone;
  final String? matricule;
  final String? zoneCouverture;

  const AgentInfoModel({
    required this.id,
    this.nom,
    this.prenom,
    this.email,
    this.telephone,
    this.matricule,
    this.zoneCouverture,
  });

  factory AgentInfoModel.fromJson(Map<String, dynamic> json) {
    return AgentInfoModel(
      id: json['agentId'] is int
          ? json['agentId']
          : int.tryParse(json['agentId']?.toString() ?? '0') ?? 0,
      nom: json['nom']?.toString(),
      prenom: json['prenom']?.toString(),
      email: json['email']?.toString(),
      telephone: json['telephone']?.toString(),
      matricule: json['matricule']?.toString(),
      zoneCouverture: json['zoneCouverture']?.toString(),
    );
  }

  @override
  List<Object?> get props => [id, nom, prenom, email, telephone, matricule, zoneCouverture];
}

class AgentStatsModel extends Equatable {
  final int total;
  final int brouillons;
  final int enAttente;
  final int validees;
  final int rejetees;
  final double tauxValidation;

  const AgentStatsModel({
    this.total = 0,
    this.brouillons = 0,
    this.enAttente = 0,
    this.validees = 0,
    this.rejetees = 0,
    this.tauxValidation = 0.0,
  });

  factory AgentStatsModel.fromJson(Map<String, dynamic> json) {
    return AgentStatsModel(
      total: json['total'] is int ? json['total'] : int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      brouillons: json['brouillons'] is int ? json['brouillons'] : int.tryParse(json['brouillons']?.toString() ?? '0') ?? 0,
      enAttente: json['enAttente'] is int ? json['enAttente'] : int.tryParse(json['enAttente']?.toString() ?? '0') ?? 0,
      validees: json['validees'] is int ? json['validees'] : int.tryParse(json['validees']?.toString() ?? '0') ?? 0,
      rejetees: json['rejetees'] is int ? json['rejetees'] : int.tryParse(json['rejetees']?.toString() ?? '0') ?? 0,
      tauxValidation: json['tauxValidation'] is num
          ? (json['tauxValidation'] as num).toDouble()
          : double.tryParse(json['tauxValidation']?.toString() ?? '0.0') ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [total, brouillons, enAttente, validees, rejetees, tauxValidation];
}

