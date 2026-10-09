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
      agentId: json['agentId'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      telephone: json['telephone'],
      matricule: json['matricule'],
      zoneCouverture: json['zoneCouverture'],
    );
  }
}
