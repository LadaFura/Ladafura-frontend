class AgentProfileModel {
  final int id;
  final String matricule;
  final String zoneCouverture;
  final String nom;
  final String prenom;
  final String email;
  final String? telephone;
  final String role;
  final String statut;
  final DateTime? dateCreation;
  final int nombreTotalCollectes;

  const AgentProfileModel({
    required this.id,
    required this.matricule,
    required this.zoneCouverture,
    required this.nom,
    required this.prenom,
    required this.email,
    this.telephone,
    required this.role,
    required this.statut,
    this.dateCreation,
    required this.nombreTotalCollectes,
  });

  String get fullName => '$prenom $nom'.trim();

  String get initials {
    final p = prenom.trim().isNotEmpty ? prenom.trim()[0].toUpperCase() : '';
    final n = nom.trim().isNotEmpty ? nom.trim()[0].toUpperCase() : '';
    final res = '$p$n';
    return res.isNotEmpty ? res : 'AG';
  }

  factory AgentProfileModel.fromJson(Map<String, dynamic> json) {
    return AgentProfileModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      matricule: json['matricule'] as String? ?? 'AGT-TERRAIN',
      zoneCouverture:
          json['zoneCouverture'] as String? ?? 'Zone non renseignée',
      nom: json['nom'] as String? ?? '',
      prenom: json['prenom'] as String? ?? '',
      email: json['email'] as String? ?? '',
      telephone: json['telephone'] as String?,
      role: json['role']?.toString() ?? 'AGENT_COLLECTE',
      statut: json['statut']?.toString() ?? 'ACTIF',
      dateCreation: json['dateCreation'] != null
          ? DateTime.tryParse(json['dateCreation'].toString())
          : null,
      nombreTotalCollectes:
          (json['nombreTotalCollectes'] as num?)?.toInt() ?? 0,
    );
  }
}

