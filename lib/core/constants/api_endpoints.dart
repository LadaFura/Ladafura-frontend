/// Constantes officielles des URLs et routes REST du backend Spring Boot LADAFURA.
///
/// L'application Flutter communique avec l'API REST exposée sur le préfixe `/api/v1`.
/// Les routes sont réparties par acteur mobile (Population, Agent de Collecte, Pharmacopée)
/// conformément à la conception du backend Java 21 / Spring Boot 3.
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

  // --- Pharmacopée ---
  static const String pharmacopeeAuthMe = '/pharmacopee/auth/me';
  static const String pharmacopeeMe = pharmacopeeAuthMe;

  // ===========================================================================
  // 👥 MODULE POPULATION (Citoyens & Visiteurs - US-01 à US-12)
  // ===========================================================================

  // --- Recherche & Découverte ---
  static const String populationRecherche = '/population/recherche';
  static const String populationRechercheSuggestions =
      '/population/recherche/suggestions';

  // --- Plantes Médicinales ---
  static const String populationPlantes = '/population/plantes';
  static String populationPlanteDetail(String id) => '/population/plantes/$id';

  // --- Produits & Remèdes Traditionnels ---
  static const String populationProduits = '/population/produits';
  static String populationProduitDetail(String id) =>
      '/population/produits/$id';

  // --- Pharmacopées & Officines ---
  static const String populationPharmacopees = '/population/pharmacopees';
  static String populationPharmacopeeDetail(String id) =>
      '/population/pharmacopees/$id';

  // --- Cartographie & Géolocalisation ---
  static const String populationCarte = '/population/carte';
  static const String populationCarteProximite = '/population/carte/proximite';

  // --- Panier d'Achat ---
  static const String populationPanier = '/population/panier';
  static const String populationPanierItems = '/population/panier/items';
  static String populationPanierItem(String itemId) =>
      '/population/panier/items/$itemId';
  static const String populationPanierClear = '/population/panier/clear';

  // --- Commandes ---
  static const String populationCommandes = '/population/commandes';
  static String populationCommandeDetail(String id) =>
      '/population/commandes/$id';
  static String populationCommandeAnnuler(String id) =>
      '/population/commandes/$id/annuler';

  // --- Paiements ---
  static const String populationPaiements = '/population/paiements';
  static const String populationPaiementInitier =
      '/population/paiements/initier';
  static String populationPaiementStatut(String id) =>
      '/population/paiements/$id/statut';

  // --- Modes de Retrait & Livraison ---
  static const String populationRetraitsModes = '/population/retraits/modes';

  // --- Favoris ---
  static const String populationFavoris = '/population/favoris';
  static String populationFavoriToggle(String id) =>
      '/population/favoris/toggle/$id';

  // --- Avis & Évaluations ---
  static const String populationAvis = '/population/avis';
  static String populationAvisProduit(String produitId) =>
      '/population/avis/produit/$produitId';

  // --- Profil Citoyen ---
  static const String populationProfile = '/population/profile';
  static const String populationProfileUpdate = '/population/profile/update';

  // --- Notifications & Historique ---
  static const String populationNotifications = '/population/notifications';
  static const String populationHistorique = '/population/historique';

  // ===========================================================================
  // 🌿 MODULE AGENT DE COLLECTE (Terrain - US-13 à US-17)
  // ===========================================================================

  // --- Tableau de bord & KPIs ---
  static const String agentDashboardStats = '/agent/dashboard/stats';
  static const String agentDashboardSummary = '/agent/dashboard/summary';

  // --- Collectes Botaniques ---
  static const String agentCollectes = '/agent/collectes';
  static String agentCollecteDetail(String id) => '/agent/collectes/$id';
  static const String agentCollectesBrouillons = '/agent/collectes/brouillons';
  static const String agentCollectesSoumissions = '/agent/submissions';
  static String agentSuiviCollecte(String id) => '/agent/suivi/$id';

  // --- Médias Terrain (Photos, Enregistrements Audio des récits traditionnels) ---
  static const String agentMediasUpload = '/agent/medias/upload';
  static String agentMediaDetail(String id) => '/agent/medias/$id';

  // --- Connaissances & Usages Traditionnels ---
  static const String agentConnaissances = '/agent/connaissances';

  // --- Sources & Informateurs (Tradipraticiens, Herboristes, Anciens) ---
  static const String agentSources = '/agent/sources';
  static String agentSourceDetail(String id) => '/agent/sources/$id';

  // --- Noms Vernaculaires (Bambara, Peul, Soninké, etc.) ---
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

  // ===========================================================================
  // 🏪 MODULE PHARMACOPÉE (Officines & Vendeurs - US-18 à US-24)
  // ===========================================================================

  // --- Tableau de bord Officine ---
  static const String pharmacopeeDashboardStats =
      '/pharmacopee/dashboard/stats';

  // --- Gestion du Catalogue Produits ---
  static const String pharmacopeeProduits = '/pharmacopee/produits';
  static String pharmacopeeProduitDetail(String id) =>
      '/pharmacopee/produits/$id';

  // --- Gestion des Stocks & Alertes ---
  static const String pharmacopeeStock = '/pharmacopee/stock';
  static String pharmacopeeStockAjuster(String id) =>
      '/pharmacopee/stock/$id/ajuster';
  static const String pharmacopeeStockAlertes = '/pharmacopee/stock/alertes';

  // --- Traitement des Commandes Reçues ---
  static const String pharmacopeeCommandes = '/pharmacopee/commandes';
  static String pharmacopeeCommandeDetail(String id) =>
      '/pharmacopee/commandes/$id';
  static String pharmacopeeCommandeStatut(String id) =>
      '/pharmacopee/commandes/$id/statut';

  // --- Retraits en Officine ---
  static const String pharmacopeeRetraits = '/pharmacopee/retraits';

  // --- Demande de Référencement ---
  static const String pharmacopeeReferencement =
      '/pharmacopee/referencement/demander';

  // --- Paiements Reçus ---
  static const String pharmacopeePaiements = '/pharmacopee/paiements';

  // --- Profil Officine, Avis & Notifications ---
  static const String pharmacopeeProfile = '/pharmacopee/profile';
  static const String pharmacopeeLocalisations = '/pharmacopee/localisations';
  static const String pharmacopeeAvis = '/pharmacopee/avis';
  static const String pharmacopeeNotifications = '/pharmacopee/notifications';
}
