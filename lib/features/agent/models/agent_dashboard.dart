class AgentDashboard {
  final int agentId;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String? matricule;
  final String zoneCouverture;

  AgentDashboard({
    required this.agentId,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    this.matricule,
    required this.zoneCouverture,
  });

  factory AgentDashboard.fromJson(Map<String, dynamic> json) {
    return AgentDashboard(
      agentId: (json['agentId'] as num?)?.toInt() ?? 0,
      nom: json['nom'] as String? ?? '',
      prenom: json['prenom'] as String? ?? '',
      email: json['email'] as String? ?? '',
      telephone: json['telephone'] as String? ?? '',
      matricule: json['matricule'] as String?,
      zoneCouverture: json['zoneCouverture'] as String? ?? 'Non définie',
    );
  }
}
