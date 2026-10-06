import '../../../shared/enums/user_role.dart';

class ProfilModel {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String? telephone;
  final UserRole role;

  const ProfilModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    this.telephone,
    required this.role,
  });

  String get nomComplet => '$prenom $nom'.trim();

  factory ProfilModel.fromJson(Map<String, dynamic> json) {
    return ProfilModel(
      id: json['id'] as int? ?? 0,
      nom: json['nom'] as String? ?? '',
      prenom: json['prenom'] as String? ?? '',
      email: json['email'] as String? ?? '',
      telephone: json['telephone'] as String?,
      role: UserRole.fromString(json['role'] as String?) ?? UserRole.population,
    );
  }
}
