import 'package:equatable/equatable.dart';

class AgentMaladieModel extends Equatable {
  final int id;
  final String nom;
  final String? description;

  const AgentMaladieModel({
    required this.id,
    required this.nom,
    this.description,
  });

  factory AgentMaladieModel.fromJson(Map<String, dynamic> json) {
    return AgentMaladieModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nom: json['nom']?.toString() ?? '',
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'description': description,
  };

  @override
  List<Object?> get props => [id, nom, description];
}

