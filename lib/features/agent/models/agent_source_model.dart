import 'package:equatable/equatable.dart';

class AgentSourceModel extends Equatable {
  final int id;
  final String nom;
  final String? prenom;
  final String nomComplet;
  final String? telephone;
  final String? email;
  final String? adresse;
  final String? specialite;
  final int? anneesExperience;
  final String? role;
  final int nombreCollectes;

  const AgentSourceModel({
    required this.id,
    required this.nom,
    this.prenom,
    required this.nomComplet,
    this.telephone,
    this.email,
    this.adresse,
    this.specialite,
    this.anneesExperience,
    this.role,
    this.nombreCollectes = 0,
  });

  factory AgentSourceModel.fromJson(Map<String, dynamic> json) {
    final nom = json['nom']?.toString() ?? '';
    final prenom = json['prenom']?.toString();
    final nomComplet = json['nomComplet']?.toString() ??
        (prenom != null && prenom.isNotEmpty ? '$prenom $nom' : nom);

    return AgentSourceModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nom: nom,
      prenom: prenom,
      nomComplet: nomComplet,
      telephone: json['telephone']?.toString(),
      email: json['email']?.toString(),
      adresse: json['adresse']?.toString(),
      specialite: json['specialite']?.toString(),
      anneesExperience: json['anneesExperience'] is int
          ? json['anneesExperience']
          : int.tryParse(json['anneesExperience']?.toString() ?? ''),
      role: json['role']?.toString(),
      nombreCollectes: json['nombreCollectes'] is int
          ? json['nombreCollectes']
          : int.tryParse(json['nombreCollectes']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'prenom': prenom,
    'nomComplet': nomComplet,
    'telephone': telephone,
    'email': email,
    'adresse': adresse,
    'specialite': specialite,
    'anneesExperience': anneesExperience,
    'role': role,
    'nombreCollectes': nombreCollectes,
  };

  @override
  List<Object?> get props => [
    id,
    nom,
    prenom,
    nomComplet,
    telephone,
    email,
    adresse,
    specialite,
    anneesExperience,
    role,
    nombreCollectes,
  ];
}

