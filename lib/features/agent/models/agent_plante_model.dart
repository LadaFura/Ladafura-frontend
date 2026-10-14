import 'package:equatable/equatable.dart';

class AgentPlanteModel extends Equatable {
  final int id;
  final String nomScientifique;
  final String? description;
  final String? photoUrl;
  final String? statut;
  final List<String> nomsVernaculaires;
  final int nombreConnaissancesTraditionnelles;

  const AgentPlanteModel({
    required this.id,
    required this.nomScientifique,
    this.description,
    this.photoUrl,
    this.statut,
    this.nomsVernaculaires = const [],
    this.nombreConnaissancesTraditionnelles = 0,
  });

  factory AgentPlanteModel.fromJson(Map<String, dynamic> json) {
    List<String> vernaculaires = [];
    if (json['nomsVernaculaires'] is List) {
      vernaculaires = (json['nomsVernaculaires'] as List).map((v) {
        if (v is Map) {
          final nom = v['nom'] ?? '';
          final langue = v['langue'] != null ? ' (${v['langue']})' : '';
          return '$nom$langue'.trim();
        }
        return v.toString();
      }).toList();
    }

    return AgentPlanteModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nomScientifique: json['nomScientifique']?.toString() ?? '',
      description: json['description']?.toString(),
      photoUrl: json['photoUrl']?.toString(),
      statut: json['statut']?.toString(),
      nomsVernaculaires: vernaculaires,
      nombreConnaissancesTraditionnelles: json['nombreConnaissancesTraditionnelles'] is int
          ? json['nombreConnaissancesTraditionnelles']
          : 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nomScientifique': nomScientifique,
    'description': description,
    'photoUrl': photoUrl,
    'statut': statut,
    'nomsVernaculaires': nomsVernaculaires,
    'nombreConnaissancesTraditionnelles': nombreConnaissancesTraditionnelles,
  };

  @override
  List<Object?> get props => [
    id,
    nomScientifique,
    description,
    photoUrl,
    statut,
    nomsVernaculaires,
    nombreConnaissancesTraditionnelles,
  ];
}

