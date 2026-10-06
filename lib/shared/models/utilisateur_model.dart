import '../enums/user_role.dart';

/// Modèle transversal représentant l'utilisateur connecté ou consulté dans LADAFURA.
///
/// Conforme à l'entité JPA `com.pharmacopee.ladafura.Models.Utilisateur`
/// et aux DTOs Spring Boot `PopulationAuthResponse`, `AgentAuthResponse`, `PharmacopeeAuthResponse`.
class UtilisateurModel {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String? firebaseUid;
  final String? telephone;
  final UserRole role;
  final String statut;
  final DateTime? dateCreation;

  // Attributs spécifiques selon le rôle
  final String? matricule;
  final String? zoneCouverture;
  final String? pharmacopeeNom;

  /// Alias de rétrocompatibilité
  String? get officineNom => pharmacopeeNom;

  const UtilisateurModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    this.firebaseUid,
    this.telephone,
    required this.role,
    this.statut = 'ACTIF',
    this.dateCreation,
    this.matricule,
    this.zoneCouverture,
    this.pharmacopeeNom,
  });

  /// Nom complet formaté (Prénom Nom).
  String get nomComplet => '$prenom $nom'.trim();

  /// Initiales pour les avatars UI (ex: "FD" pour Fatoumata Diarra).
  String get initiales {
    final p = prenom.isNotEmpty ? prenom[0].toUpperCase() : '';
    final n = nom.isNotEmpty ? nom[0].toUpperCase() : '';
    return '$p$n';
  }

  /// Indique si le compte est actif.
  bool get isActif => statut.toUpperCase() == 'ACTIF';

  /// Indique si l'utilisateur est un citoyen (Population).
  bool get isCitizen => role == UserRole.population;

  /// Indique si l'utilisateur est un agent de collecte terrain.
  bool get isAgent => role == UserRole.agentCollecte;

  UtilisateurModel copyWith({
    int? id,
    String? nom,
    String? prenom,
    String? email,
    String? firebaseUid,
    String? telephone,
    UserRole? role,
    String? statut,
    DateTime? dateCreation,
    String? matricule,
    String? zoneCouverture,
    String? pharmacopeeNom,
  }) {
    return UtilisateurModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      telephone: telephone ?? this.telephone,
      role: role ?? this.role,
      statut: statut ?? this.statut,
      dateCreation: dateCreation ?? this.dateCreation,
      matricule: matricule ?? this.matricule,
      zoneCouverture: zoneCouverture ?? this.zoneCouverture,
      pharmacopeeNom: pharmacopeeNom ?? this.pharmacopeeNom,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'firebaseUid': firebaseUid,
        'telephone': telephone,
        'role': role.value,
        'statut': statut,
        'dateCreation': dateCreation?.toIso8601String(),
        'matricule': matricule,
        'zoneCouverture': zoneCouverture,
        'pharmacopeeNom': pharmacopeeNom,
      };

  factory UtilisateurModel.fromJson(Map<String, dynamic> json) {
    return UtilisateurModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nom: json['nom']?.toString() ?? '',
      prenom: json['prenom']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firebaseUid: json['firebaseUid']?.toString(),
      telephone: json['telephone']?.toString(),
      role:
          UserRole.fromString(json['role']?.toString()) ?? UserRole.population,
      statut: json['statut']?.toString() ?? 'ACTIF',
      dateCreation: json['dateCreation'] != null
          ? DateTime.tryParse(json['dateCreation'].toString())
          : null,
      matricule: json['matricule']?.toString(),
      zoneCouverture: json['zoneCouverture']?.toString(),
      pharmacopeeNom:
          (json['pharmacopeeNom'] ?? json['officineNom'])?.toString(),
    );
  }

  @override
  String toString() =>
      'UtilisateurModel(id: $id, nom: $nomComplet, role: ${role.value}, email: $email)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UtilisateurModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          role == other.role;

  @override
  int get hashCode => id.hashCode ^ email.hashCode ^ role.hashCode;
}
