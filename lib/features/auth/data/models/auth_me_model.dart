import 'package:ladafura_frontend_flutter/shared/enums/user_role.dart';
import 'package:ladafura_frontend_flutter/shared/models/utilisateur_model.dart';

/// DTO de réponse pour l'endpoint neutre `/api/v1/auth/me`.
class AuthMeModel {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String? telephone;
  final UserRole role;
  final String statut;
  final String? firebaseUid;
  final DateTime? dateCreation;

  const AuthMeModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    this.telephone,
    required this.role,
    this.statut = 'ACTIF',
    this.firebaseUid,
    this.dateCreation,
  });

  factory AuthMeModel.fromJson(Map<String, dynamic> json) {
    return AuthMeModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nom: json['nom']?.toString() ?? '',
      prenom: json['prenom']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      telephone: json['telephone']?.toString(),
      role:
          UserRole.fromString(json['role']?.toString()) ?? UserRole.population,
      statut: json['statut']?.toString() ?? 'ACTIF',
      firebaseUid: json['firebaseUid']?.toString(),
      dateCreation: json['dateCreation'] != null
          ? DateTime.tryParse(json['dateCreation'].toString())
          : null,
    );
  }

  /// Convertit ce DTO vers le modèle métier partagé [UtilisateurModel].
  UtilisateurModel toUtilisateurModel() {
    return UtilisateurModel(
      id: id,
      nom: nom,
      prenom: prenom,
      email: email,
      telephone: telephone,
      role: role,
      statut: statut,
      firebaseUid: firebaseUid,
      dateCreation: dateCreation,
    );
  }
}
