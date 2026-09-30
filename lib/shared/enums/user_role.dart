/// Énumération des rôles utilisateurs de l'écosystème LADAFURA.
///
/// Conforme à `com.pharmacopee.ladafura.enums.Role` du backend Spring Boot.
/// L'application mobile cible en priorité :
/// - [population] : Citoyen consultant la flore, achetant des remèdes (US-01 à US-12).
/// - [agentCollecte] : Agent de terrain collectant les savoirs traditionnels et plantes (US-13 à US-17).
/// - [pharmacopee] : Officine / vendeuse gérant les stocks et commandes (US-18 à US-24).
enum UserRole {
  population,
  agentCollecte,
  pharmacopee,
  administrateur,
  therapeute,
  herboriste;

  /// Valeur textuelle exacte attendue par les APIs Spring Boot et les jetons JWT.
  String get value {
    switch (this) {
      case UserRole.population:
        return 'POPULATION';
      case UserRole.agentCollecte:
        return 'AGENT_COLLECTE';
      case UserRole.pharmacopee:
        return 'PHARMACOPEE';
      case UserRole.administrateur:
        return 'ADMINISTRATEUR';
      case UserRole.therapeute:
        return 'THERAPEUTE';
      case UserRole.herboriste:
        return 'HERBORISTE';
    }
  }

  /// Alias pour la valeur backend Spring Boot.
  String get backendValue => value;

  /// Libellé convivial en français pour l'interface utilisateur.
  String get label {
    switch (this) {
      case UserRole.population:
        return 'Citoyen';
      case UserRole.agentCollecte:
        return 'Agent de collecte';
      case UserRole.pharmacopee:
        return 'Officine / Pharmacopée';
      case UserRole.administrateur:
        return 'Administrateur (Web)';
      case UserRole.therapeute:
        return 'Thérapeute';
      case UserRole.herboriste:
        return 'Herboriste';
    }
  }

  /// Indique si le rôle fait partie des 3 acteurs mobiles principaux.
  bool get isMobileActor =>
      this == UserRole.population ||
      this == UserRole.agentCollecte ||
      this == UserRole.pharmacopee;

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
