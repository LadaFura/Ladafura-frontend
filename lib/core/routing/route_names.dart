/// Définition centralisée et unique des identifiants et des chemins d'accès (URLs) de l'application LADAFURA.
///
/// Conforme au découpage des 3 espaces de navigation mobiles :
/// 1. Espace Visiteur (Consultation publique anonyme)
/// 2. Espace Citoyen / Population (US-01 à US-12)
/// 3. Espace Agent de Collecte Terrain (US-13 à US-17)
/// 4. Espace Officine Pharmacopée (US-18 à US-24)
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

  static const String visitorPlanteDetail = 'visitor-plante-detail';
  static const String visitorPlanteDetailPath = '/visitor/plantes/:id';
  static String visitorPlanteDetailUrl(String id) => '/visitor/plantes/$id';

  static const String visitorProduitDetail = 'visitor-produit-detail';
  static const String visitorProduitDetailPath = '/visitor/produits/:id';
  static String visitorProduitDetailUrl(String id) => '/visitor/produits/$id';

  static const String visitorCarte = 'visitor-carte';
  static const String visitorCartePath = '/visitor/carte';

  // ===========================================================================
  // 3. ESPACE CITOYEN / POPULATION (US-01 À US-12)
  // ===========================================================================
  static const String citizenHome = 'citizen-home';
  static const String citizenHomePath = '/citizen';

  static const String citizenRecherche = 'citizen-recherche';
  static const String citizenRecherchePath = '/citizen/recherche';

  static const String citizenPlanteDetail = 'citizen-plante-detail';
  static const String citizenPlanteDetailPath = '/citizen/plantes/:id';
  static String citizenPlanteDetailUrl(String id) => '/citizen/plantes/$id';

  static const String citizenProduitDetail = 'citizen-produit-detail';
  static const String citizenProduitDetailPath = '/citizen/produits/:id';
  static String citizenProduitDetailUrl(String id) => '/citizen/produits/$id';

  static const String citizenMarketplace = 'citizen-marketplace';
  static const String citizenMarketplacePath = '/citizen/marketplace';

  static const String citizenCarte = 'citizen-carte';
  static const String citizenCartePath = '/citizen/carte';

  static const String citizenPanier = 'citizen-panier';
  static const String citizenPanierPath = '/citizen/panier';

  static const String citizenModeRetrait = 'citizen-mode-retrait';
  static const String citizenModeRetraitPath = '/citizen/panier/mode-retrait';

  static const String citizenPaiement = 'citizen-paiement';
  static const String citizenPaiementPath = '/citizen/panier/paiement';

  static const String citizenCommandes = 'citizen-commandes';
  static const String citizenCommandesPath = '/citizen/commandes';

  static const String citizenCommandeDetail = 'citizen-commande-detail';
  static const String citizenCommandeDetailPath = '/citizen/commandes/:id';
  static String citizenCommandeDetailUrl(String id) => '/citizen/commandes/$id';

  static const String citizenRedigerAvis = 'citizen-rediger-avis';
  static const String citizenRedigerAvisPath = '/citizen/commandes/:id/avis';
  static String citizenRedigerAvisUrl(String id) =>
      '/citizen/commandes/$id/avis';

  static const String citizenFavoris = 'citizen-favoris';
  static const String citizenFavorisPath = '/citizen/favoris';

  static const String citizenProfil = 'citizen-profil';
  static const String citizenProfilPath = '/citizen/profil';

  static const String citizenDepenses = 'citizen-depenses';
  static const String citizenDepensesPath = '/citizen/profil/depenses';

  // ===========================================================================
  // 4. ESPACE AGENT DE COLLECTE TERRAIN (US-13 À US-17)
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

  // ===========================================================================
  // 5. ESPACE PHARMACOPÉE / OFFICINE (US-18 À US-24)
  // ===========================================================================
  static const String pharmacopeeDashboard = 'pharmacopee-dashboard';
  static const String pharmacopeeDashboardPath = '/pharmacopee';
  static const String pharmacopeeHomePath = pharmacopeeDashboardPath;

  static const String pharmacopeeStock = 'pharmacopee-stock';
  static const String pharmacopeeStockPath = '/pharmacopee/stock';

  static const String pharmacopeeAjouterProduit = 'pharmacopee-ajouter-produit';
  static const String pharmacopeeAjouterProduitPath =
      '/pharmacopee/stock/ajouter';

  static const String pharmacopeeModesRetrait = 'pharmacopee-modes-retrait';
  static const String pharmacopeeModesRetraitPath =
      '/pharmacopee/modes-retrait';

  static const String pharmacopeeCommandes = 'pharmacopee-commandes';
  static const String pharmacopeeCommandesPath = '/pharmacopee/commandes';

  static const String pharmacopeeCommandeDetail = 'pharmacopee-commande-detail';
  static const String pharmacopeeCommandeDetailPath =
      '/pharmacopee/commandes/:id';
  static String pharmacopeeCommandeDetailUrl(String id) =>
      '/pharmacopee/commandes/$id';

  static const String pharmacopeeValiderPickup = 'pharmacopee-valider-pickup';
  static const String pharmacopeeValiderPickupPath =
      '/pharmacopee/commandes/:id/valider-pickup';
  static String pharmacopeeValiderPickupUrl(String id) =>
      '/pharmacopee/commandes/$id/valider-pickup';

  static const String pharmacopeeAvis = 'pharmacopee-avis';
  static const String pharmacopeeAvisPath = '/pharmacopee/avis';

  static const String pharmacopeeProfil = 'pharmacopee-profil';
  static const String pharmacopeeProfilPath = '/pharmacopee/profil';

  static const String pharmacopeeReferencement = 'pharmacopee-referencement';
  static const String pharmacopeeReferencementPath =
      '/pharmacopee/referencement';
}
