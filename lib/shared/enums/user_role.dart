/// Énumération des rôles utilisateurs de l'application mobile LADAFURA.
///
/// L'application mobile cible exclusivement les 2 acteurs suivants :
/// - [population] : Citoyen, chercheur ou visiteur consultant la flore et les savoirs traditionnels.
/// - [agentCollecte] : Agent de terrain collectant les spécimens et savoirs botaniques.
enum UserRole {
  population,
  agentCollecte;

  /// Valeur textuelle exacte attendue par les APIs Spring Boot et les jetons JWT.
  String get value {
    switch (this) {
      case UserRole.population:
        return 'POPULATION';
      case UserRole.agentCollecte:
        return 'AGENT_COLLECTE';
    }
  }

  /// Alias pour la valeur backend Spring Boot.
  String get backendValue => value;

  /// Libellé convivial en français pour l'interface utilisateur.
  String get label {
    switch (this) {
      case UserRole.population:
        return 'Citoyen / Chercheur';
      case UserRole.agentCollecte:
        return 'Agent de collecte';
    }
  }

  /// Indique si le rôle fait partie des acteurs mobiles autorisés.
  bool get isMobileActor => true;

  /// Liste des rôles autorisés sur l'application mobile.
  static List<UserRole> get mobileRoles => [
        UserRole.population,
        UserRole.agentCollecte,
      ];

  /// Parse un rôle depuis une chaîne de caractères (insensible à la casse).
  static UserRole? fromString(String? roleStr) {
    if (roleStr == null || roleStr.isEmpty) return null;
    final normalized = roleStr.trim().toUpperCase();
    for (final role in UserRole.values) {
      if (role.value == normalized) return role;
    }
    return null;
  }
}
