import 'package:ladafura_frontend_flutter/shared/enums/user_role.dart';

/// Données de requête pour la connexion d'un utilisateur.
///
/// La connexion s'effectue via Firebase Auth (Email + Mot de passe),
/// puis synchronisation avec le rôle sélectionné (ou détecté).
class LoginRequestModel {
  final String email;
  final String motDePasse;
  final UserRole role;

  const LoginRequestModel({
    required this.email,
    required this.motDePasse,
    this.role = UserRole.population,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'motDePasse': motDePasse,
        'role': role.backendValue,
      };

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) {
    return LoginRequestModel(
      email: json['email']?.toString() ?? '',
      motDePasse: json['motDePasse']?.toString() ?? '',
      role:
          UserRole.fromString(json['role']?.toString()) ?? UserRole.population,
    );
  }
}
