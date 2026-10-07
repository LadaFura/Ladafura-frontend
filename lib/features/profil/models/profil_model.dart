import '../../../shared/enums/user_role.dart';

/// Modèle métier complet du profil Citoyen (Population),
/// conforme au DTO backend `PopulationProfileResponse`.
class ProfilModel {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String? telephone;
  final UserRole role;
  final String statut;
  final String? firebaseUid;
  final DateTime? dateCreation;
  final int nombreTotalCommandes;
  final int nombreTotalFavoris;

  const ProfilModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    this.telephone,
    required this.role,
    this.statut = 'ACTIF',
    this.firebaseUid,
    this.dateCreation,
    this.nombreTotalCommandes = 0,
    this.nombreTotalFavoris = 0,
  });

  /// Nom complet formaté (Prénom Nom).
  String get nomComplet => '$prenom $nom'.trim();

  /// Initiales pour l'avatar utilisateur générique.
  String get initiales {
    final p = prenom.isNotEmpty ? prenom[0].toUpperCase() : '';
    final n = nom.isNotEmpty ? nom[0].toUpperCase() : '';
    return '$p$n'.isNotEmpty ? '$p$n' : 'P';
  }

  factory ProfilModel.fromJson(Map<String, dynamic> json) {
    return ProfilModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nom: json['nom']?.toString() ?? '',
      prenom: json['prenom']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      telephone: json['telephone']?.toString(),
      role: UserRole.fromString(json['role']?.toString()) ?? UserRole.population,
      statut: json['statut']?.toString() ?? 'ACTIF',
      firebaseUid: json['firebaseUid']?.toString(),
      dateCreation: json['dateCreation'] != null
          ? DateTime.tryParse(json['dateCreation'].toString())
          : null,
      nombreTotalCommandes:
          (json['nombreTotalCommandes'] as num?)?.toInt() ?? 0,
      nombreTotalFavoris:
          (json['nombreTotalFavoris'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'telephone': telephone,
        'role': role.name,
        'statut': statut,
        'firebaseUid': firebaseUid,
        'dateCreation': dateCreation?.toIso8601String(),
        'nombreTotalCommandes': nombreTotalCommandes,
        'nombreTotalFavoris': nombreTotalFavoris,
      };

  ProfilModel copyWith({
    int? id,
    String? nom,
    String? prenom,
    String? email,
    String? telephone,
    UserRole? role,
    String? statut,
    String? firebaseUid,
    DateTime? dateCreation,
    int? nombreTotalCommandes,
    int? nombreTotalFavoris,
  }) {
    return ProfilModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      role: role ?? this.role,
      statut: statut ?? this.statut,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      dateCreation: dateCreation ?? this.dateCreation,
      nombreTotalCommandes: nombreTotalCommandes ?? this.nombreTotalCommandes,
      nombreTotalFavoris: nombreTotalFavoris ?? this.nombreTotalFavoris,
    );
  }
}
