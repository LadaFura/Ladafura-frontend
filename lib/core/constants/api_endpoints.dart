/// Constantes officielles des URLs et routes REST du backend Spring Boot LADAFURA.
///
/// L'application Flutter mobile communique avec l'API REST exposée sur le préfixe `/api/v1`.
/// Les routes sont réparties strictement selon les deux acteurs mobiles du projet :
/// 1. Population (Citoyens, Chercheurs, Visiteurs - US-01 à US-06)
/// 2. Agent de Collecte Terrain (Botanistes, Enquêteurs - US-13 à US-17)
class ApiEndpoints {
  ApiEndpoints._();

  // ===========================================================================
  // 🌐 CONFIGURATION DE BASE
  // ===========================================================================

  /// Hôte par défaut en local pour simulateur iOS et Web
  static const String defaultHost = 'http://localhost:8080';

  /// Hôte pour émulateur Android (redirection vers la machine hôte)
  static const String androidEmulatorHost = 'http://10.0.2.2:8080';

  /// Préfixe global des routes REST version 1
  static const String apiVersion = '/api/v1';

  /// URL de base par défaut (configurable dynamiquement selon l'environnement)
  static String baseUrl = '$defaultHost$apiVersion';

  /// Délais d'expiration adaptés aux conditions réseau du Mali (15 secondes)
  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);

  // ===========================================================================
  // 🔐 AUTHENTIFICATION & SESSIONS
  // ===========================================================================

  // --- Citoyen / Population ---
  static const String populationAuthRegister = '/population/auth/register';
  static const String populationRegister = populationAuthRegister;
  static const String populationAuthSync = '/population/auth/sync';
  static const String populationSync = populationAuthSync;
  static const String populationAuthMe = '/population/auth/me';
  static const String populationMe = populationAuthMe;

  // --- Agent de Collecte ---
  static const String agentAuthMe = '/agent/auth/me';
  static const String agentMe = agentAuthMe;

  // ===========================================================================
  // 👥 MODULE POPULATION (Citoyens & Visiteurs)
  // ===========================================================================

  // --- Recherche & Découverte Flore ---
  static const String populationRecherche = '/population/recherche';
  static const String populationRecherchePlantes =
      '/population/recherche/plantes';
  static const String populationRechercheVernaculaires =
      '/population/recherche/vernaculaires';
  static const String populationRechercheMaladies =
      '/population/recherche/maladies';

  // --- Plantes Médicinales Maliennes ---
  static const String populationPlantes = '/population/plantes';
  static String populationPlanteDetail(String id) => '/population/plantes/$id';
  static String populationPlanteConnaissances(String id) =>
      '/population/plantes/$id/connaissances';
  static String populationPlanteEtudes(String id) =>
      '/population/plantes/$id/etudes';

  // --- Favoris (Bookmarks personnels) ---
  static const String populationFavoris = '/population/favoris';
  static const String populationFavorisPlantes = '/population/favoris/plantes';
  static String populationFavoriPlanteToggle(String planteId) =>
      '/population/favoris/plantes/$planteId';
  static const String populationFavorisCheck = '/population/favoris/check';
  static const String populationFavorisCount = '/population/favoris/count';

  // --- Profil Citoyen ---
  static const String populationProfile = '/population/profile';
  static const String populationProfileUpdate = '/population/profile/update';

  // --- Notifications & Historique ---
  static const String populationNotifications = '/population/notifications';
  static const String populationHistorique = '/population/historique';

  // ===========================================================================
  // 🌿 MODULE AGENT DE COLLECTE (Terrain - US-13 à US-17)
  // ===========================================================================

  // --- Tableau de bord & Activités ---
  static const String agentDashboardStats = '/agent/dashboard/stats';
  static const String agentDashboardSummary = '/agent/dashboard/summary';

  // --- Collectes Botaniques ---
  static const String agentCollectes = '/agent/collectes';
  static String agentCollecteDetail(String id) => '/agent/collectes/$id';
  static const String agentCollectesDraft = '/agent/collectes/draft';
  static String agentCollecteRecapitulatif(String id) =>
      '/agent/collectes/$id/recapitulatif';
  static String agentCollecteSoumettre(String id) =>
      '/agent/collectes/$id/soumettre';

  // --- Médias Terrain & Enregistrement Audio des récits (US-15) ---
  static const String agentMediasUpload = '/agent/medias/upload';
  static String agentMediaDetail(String id) => '/agent/medias/$id';

  // --- Connaissances & Usages Traditionnels ---
  static const String agentConnaissances = '/agent/connaissances';

  // --- Sources & Informateurs (Tradipraticiens, Herboristes) ---
  static const String agentSources = '/agent/sources';
  static String agentSourceDetail(String id) => '/agent/sources/$id';

  // --- Noms Vernaculaires en langues locales du Mali ---
  static const String agentNomsVernaculaires = '/agent/noms-vernaculaires';

  // --- Localisation & Découpage Territorial Malien (Région, Cercle, Commune, GPS) ---
  static const String agentLocalisations = '/agent/localisations';
  static const String agentLocalisationsHierarchie =
      '/agent/localisations/hierarchie';

  // --- Référentiel des Plantes pour Agents ---
  static const String agentPlantes = '/agent/plantes';

  // --- Notifications & Profil Agent ---
  static const String agentNotifications = '/agent/notifications';
  static const String agentProfile = '/agent/profile';
}
