import 'package:ladafura_frontend_flutter/shared/enums/user_role.dart';

/// Données de requête pour l'inscription d'un nouvel utilisateur.
///
/// Conforme au DTO backend `PopulationRegisterRequest.java` avec support
/// de l'aiguillage multi-rôles (Citoyen, Agent de collecte, Pharmacopée).
class RegisterRequestModel {
  final String nom;
  final String prenom;
  final String email;
  final String motDePasse;
  final String? telephone;
  final UserRole role;

  // Champs complémentaires optionnels selon le rôle
  final String? matricule;
  final String? nomPharmacopee;
  final String? zoneCollecte;

  /// Alias de rétrocompatibilité
  String? get nomOfficine => nomPharmacopee;

  const RegisterRequestModel({
    required this.nom,
    required this.prenom,
    required this.email,
    required this.motDePasse,
    this.telephone,
    this.role = UserRole.population,
    this.matricule,
    String? nomPharmacopee,
    String? nomOfficine,
    this.zoneCollecte,
  }) : nomPharmacopee = nomPharmacopee ?? nomOfficine;

  /// Sérialisation conforme à l'API Spring Boot `POST /api/v1/population/auth/register`.
  Map<String, dynamic> toBackendJson() => {
        'nom': nom.trim(),
        'prenom': prenom.trim(),
        'email': email.trim().toLowerCase(),
        'motDePasse': motDePasse,
        if (telephone != null && telephone!.trim().isNotEmpty)
          'telephone': telephone!.trim(),
      };

  Map<String, dynamic> toJson() => {
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'motDePasse': motDePasse,
        'telephone': telephone,
        'role': role.backendValue,
        'matricule': matricule,
        'nomPharmacopee': nomPharmacopee,
        'zoneCollecte': zoneCollecte,
      };

  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) {
    return RegisterRequestModel(
      nom: json['nom']?.toString() ?? '',
      prenom: json['prenom']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      motDePasse: json['motDePasse']?.toString() ?? '',
      telephone: json['telephone']?.toString(),
      role:
          UserRole.fromString(json['role']?.toString()) ?? UserRole.population,
      matricule: json['matricule']?.toString(),
      nomPharmacopee:
          (json['nomPharmacopee'] ?? json['nomOfficine'])?.toString(),
      zoneCollecte: json['zoneCollecte']?.toString(),
    );
  }
}
