/// Définition centralisée et unique des identifiants et des chemins d'accès (URLs) de l'application LADAFURA.
///
/// Conforme au nouveau périmètre restreint aux 2 acteurs mobiles :
/// 1. Espace Visiteur (Consultation publique libre de la flore)
/// 2. Espace Citoyen / Population (Consultation des plantes médicinales, savoirs et études)
/// 3. Espace Agent de Collecte Terrain (Collectes botaniques, GPS, enregistrements oraux)
class RouteNames {
  RouteNames._();

  // ===========================================================================
  // 1. DÉMARRAGE & AUTHENTIFICATION
  // ===========================================================================
  static const String splash = 'splash';
  static const String splashPath = '/';

  static const String onboarding = 'onboarding';
  static const String onboardingPath = '/onboarding';

  static const String login = 'login';
  static const String loginPath = '/auth/login';

  static const String register = 'register';
  static const String registerPath = '/auth/register';

  static const String roleSelection = 'role-selection';
  static const String roleSelectionPath = '/auth/role-selection';

  // ===========================================================================
  // 2. ESPACE VISITEUR (PUBLIC SANS CONNEXION)
  // ===========================================================================
  static const String visitorHome = 'visitor-home';
  static const String visitorHomePath = '/visitor';

  static const String visitorRecherche = 'visitor-recherche';
  static const String visitorRecherchePath = '/visitor/recherche';

  static const String visitorCarte = 'visitor-carte';
  static const String visitorCartePath = '/visitor/carte';

  static const String visitorPanier = 'visitor-panier';
  static const String visitorPanierPath = '/visitor/panier';

  static const String visitorProfil = 'visitor-profil';
  static const String visitorProfilPath = '/visitor/profil';

  static const String visitorPlanteDetail = 'visitor-plante-detail';
  static const String visitorPlanteDetailPath = '/visitor/plantes/:id';
  static String visitorPlanteDetailUrl(String id) => '/visitor/plantes/$id';

  static const String visitorPharmacopeeDetail = 'visitor-pharmacopee-detail';
  static const String visitorPharmacopeeDetailPath = '/visitor/pharmacopees/:id';
  static String visitorPharmacopeeDetailUrl(String id) => '/visitor/pharmacopees/$id';

  // ===========================================================================
  // 3. ESPACE CITOYEN / POPULATION (FLORE & SAVOIRS)
  // ===========================================================================
  static const String citizenHome = 'citizen-home';
  static const String citizenHomePath = '/citizen';

  static const String citizenRecherche = 'citizen-recherche';
  static const String citizenRecherchePath = '/citizen/recherche';

  static const String citizenPlanteDetail = 'citizen-plante-detail';
  static const String citizenPlanteDetailPath = '/citizen/plantes/:id';
  static String citizenPlanteDetailUrl(String id) => '/citizen/plantes/$id';

  static const String citizenPharmacopeeDetail = 'citizen-pharmacopee-detail';
  static const String citizenPharmacopeeDetailPath = '/citizen/pharmacopees/:id';
  static String citizenPharmacopeeDetailUrl(String id) => '/citizen/pharmacopees/$id';

  static const String citizenCarte = 'citizen-carte';
  static const String citizenCartePath = '/citizen/carte';

  static const String citizenFavoris = 'citizen-favoris';
  static const String citizenFavorisPath = '/citizen/favoris';

  static const String citizenPanier = 'citizen-panier';
  static const String citizenPanierPath = '/citizen/panier';

  static const String citizenCommandes = 'citizen-commandes';
  static const String citizenCommandesPath = '/citizen/commandes';

  static const String citizenProfil = 'citizen-profil';
  static const String citizenProfilPath = '/citizen/profil';

  // ===========================================================================
  // 4. ESPACE AGENT DE COLLECTE TERRAIN (BOTANIQUE & TERRAIN)
  // ===========================================================================
  static const String agentDashboard = 'agent-dashboard';
  static const String agentDashboardPath = '/agent';
  static const String agentHomePath = agentDashboardPath;

  static const String agentCollectes = 'agent-collectes';
  static const String agentCollectesPath = '/agent/collectes';

  static const String agentNouvelleCollecte = 'agent-nouvelle-collecte';
  static const String agentNouvelleCollectePath = '/agent/collectes/nouvelle';

  static const String agentCollecteDetail = 'agent-collecte-detail';
  static const String agentCollecteDetailPath = '/agent/collectes/:id';
  static String agentCollecteDetailUrl(String id) => '/agent/collectes/$id';

  static const String agentModifierCollecte = 'agent-modifier-collecte';
  static const String agentModifierCollectePath =
      '/agent/collectes/:id/modifier';
  static String agentModifierCollecteUrl(String id) =>
      '/agent/collectes/$id/modifier';

  static const String agentSources = 'agent-sources';
  static const String agentSourcesPath = '/agent/sources';

  static const String agentProfil = 'agent-profil';
  static const String agentProfilPath = '/agent/profil';
}
