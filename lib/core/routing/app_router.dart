import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/auth.dart';
import '../../shared/enums/user_role.dart';
import 'route_guard.dart';
import 'route_names.dart';

part 'app_router.g.dart';

/// Clé globale de navigation permettant la navigation sans contexte si nécessaire.
final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'rootNavigator');

/// Modèle d'état d'authentification pour le routeur.
class AuthRoutingState extends ChangeNotifier {
  bool _isAuthenticated = false;
  UserRole? _role;
  bool _isInitializing = false;

  bool get isAuthenticated => _isAuthenticated;
  UserRole? get role => _role;
  bool get isInitializing => _isInitializing;

  void update({
    required bool isAuthenticated,
    required UserRole? role,
    bool isInitializing = false,
  }) {
    if (_isAuthenticated != isAuthenticated ||
        _role != role ||
        _isInitializing != isInitializing) {
      _isAuthenticated = isAuthenticated;
      _role = role;
      _isInitializing = isInitializing;
      notifyListeners();
    }
  }
}

/// Fournisseur Riverpod de l'état d'authentification pour la navigation.
@Riverpod(keepAlive: true)
AuthRoutingState authRoutingState(AuthRoutingStateRef ref) {
  return AuthRoutingState();
}

/// Fournisseur Riverpod central du [GoRouter].
@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  final authNotifier = ref.watch(authRoutingStateProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RouteNames.splashPath,
    refreshListenable: authNotifier,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      return RouteGuard.guardRedirect(
        context: context,
        state: state,
        isAuthenticated: authNotifier.isAuthenticated,
        role: authNotifier.role,
        isInitializing: authNotifier.isInitializing,
      );
    },
    routes: [
      // 1. Splash & Initialisation
      GoRoute(
        path: RouteNames.splashPath,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // 2. Authentification & Onboarding
      GoRoute(
        path: RouteNames.onboardingPath,
        name: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RouteNames.loginPath,
        name: RouteNames.login,
        builder: (context, state) {
          final roleStr = state.uri.queryParameters['role'];
          final role = UserRole.fromString(roleStr) ?? UserRole.population;
          return LoginScreen(initialRole: role);
        },
      ),
      GoRoute(
        path: RouteNames.registerPath,
        name: RouteNames.register,
        builder: (context, state) {
          final roleStr = state.uri.queryParameters['role'];
          final role = UserRole.fromString(roleStr) ?? UserRole.population;
          return RegisterScreen(initialRole: role);
        },
      ),
      GoRoute(
        path: RouteNames.roleSelectionPath,
        name: RouteNames.roleSelection,
        builder: (context, state) => const RoleSelectionScreen(),
      ),

      // 3. Espace Visiteur (Public)
      GoRoute(
        path: RouteNames.visitorHomePath,
        name: RouteNames.visitorHome,
        builder: (context, state) =>
            const _RoutePlaceholder(title: 'Accueil Visiteur'),
        routes: [
          GoRoute(
            path: 'recherche',
            name: RouteNames.visitorRecherche,
            builder: (context, state) =>
                const _RoutePlaceholder(title: 'Recherche Publique'),
          ),
          GoRoute(
            path: 'plantes/:id',
            name: RouteNames.visitorPlanteDetail,
            builder: (context, state) => _RoutePlaceholder(
              title: 'Détail Plante (${state.pathParameters['id']})',
            ),
          ),
          GoRoute(
            path: 'produits/:id',
            name: RouteNames.visitorProduitDetail,
            builder: (context, state) => _RoutePlaceholder(
              title: 'Détail Produit (${state.pathParameters['id']})',
            ),
          ),
          GoRoute(
            path: 'carte',
            name: RouteNames.visitorCarte,
            builder: (context, state) =>
                const _RoutePlaceholder(title: 'Carte Officines Publique'),
          ),
        ],
      ),

      // 4. Espace Citoyen / Population (US-01 à US-12)
      GoRoute(
        path: RouteNames.citizenHomePath,
        name: RouteNames.citizenHome,
        builder: (context, state) =>
            const _RoutePlaceholder(title: 'Accueil Citoyen'),
        routes: [
          GoRoute(
            path: 'recherche',
            name: RouteNames.citizenRecherche,
            builder: (context, state) =>
                const _RoutePlaceholder(title: 'Recherche Citoyen'),
          ),
          GoRoute(
            path: 'plantes/:id',
            name: RouteNames.citizenPlanteDetail,
            builder: (context, state) => _RoutePlaceholder(
              title: 'Plante Citoyen (${state.pathParameters['id']})',
            ),
          ),
          GoRoute(
            path: 'produits/:id',
            name: RouteNames.citizenProduitDetail,
            builder: (context, state) => _RoutePlaceholder(
              title: 'Produit Citoyen (${state.pathParameters['id']})',
            ),
          ),
          GoRoute(
            path: 'marketplace',
            name: RouteNames.citizenMarketplace,
            builder: (context, state) =>
                const _RoutePlaceholder(title: 'Marketplace Remèdes'),
          ),
          GoRoute(
            path: 'carte',
            name: RouteNames.citizenCarte,
            builder: (context, state) =>
                const _RoutePlaceholder(title: 'Carte Proximité GPS'),
          ),
          GoRoute(
            path: 'panier',
            name: RouteNames.citizenPanier,
            builder: (context, state) =>
                const _RoutePlaceholder(title: 'Panier Citoyen'),
            routes: [
              GoRoute(
                path: 'mode-retrait',
                name: RouteNames.citizenModeRetrait,
                builder: (context, state) =>
                    const _RoutePlaceholder(title: 'Choix Mode Retrait'),
              ),
              GoRoute(
                path: 'paiement',
                name: RouteNames.citizenPaiement,
                builder: (context, state) => const _RoutePlaceholder(
                    title: 'Paiement Mobile Money / Cash'),
              ),
            ],
          ),
          GoRoute(
            path: 'commandes',
            name: RouteNames.citizenCommandes,
            builder: (context, state) =>
                const _RoutePlaceholder(title: 'Mes Commandes'),
            routes: [
              GoRoute(
                path: ':id',
                name: RouteNames.citizenCommandeDetail,
                builder: (context, state) => _RoutePlaceholder(
                  title: 'Détail Commande (${state.pathParameters['id']})',
                ),
                routes: [
                  GoRoute(
                    path: 'avis',
                    name: RouteNames.citizenRedigerAvis,
                    builder: (context, state) => _RoutePlaceholder(
                      title: 'Rédiger un avis (${state.pathParameters['id']})',
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: 'favoris',
            name: RouteNames.citizenFavoris,
            builder: (context, state) =>
                const _RoutePlaceholder(title: 'Favoris Sauvegardés'),
          ),
          GoRoute(
            path: 'profil',
            name: RouteNames.citizenProfil,
            builder: (context, state) =>
                const _RoutePlaceholder(title: 'Profil Citoyen'),
            routes: [
              GoRoute(
                path: 'depenses',
                name: RouteNames.citizenDepenses,
                builder: (context, state) =>
                    const _RoutePlaceholder(title: 'Historique Dépenses'),
              ),
            ],
          ),
        ],
      ),

      // 5. Espace Agent de Collecte Terrain (US-13 à US-17)
      GoRoute(
        path: RouteNames.agentDashboardPath,
        name: RouteNames.agentDashboard,
        builder: (context, state) =>
            const _RoutePlaceholder(title: 'Tableau de bord Agent'),
        routes: [
          GoRoute(
            path: 'collectes',
            name: RouteNames.agentCollectes,
            builder: (context, state) =>
                const _RoutePlaceholder(title: 'Collectes Terrain'),
            routes: [
              GoRoute(
                path: 'nouvelle',
                name: RouteNames.agentNouvelleCollecte,
                builder: (context, state) =>
                    const _RoutePlaceholder(title: 'Nouvelle Collecte Wizard'),
              ),
              GoRoute(
                path: ':id',
                name: RouteNames.agentCollecteDetail,
                builder: (context, state) => _RoutePlaceholder(
                  title: 'Détail Collecte (${state.pathParameters['id']})',
                ),
                routes: [
                  GoRoute(
                    path: 'modifier',
                    name: RouteNames.agentModifierCollecte,
                    builder: (context, state) => _RoutePlaceholder(
                      title:
                          'Modifier Collecte (${state.pathParameters['id']})',
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: 'sources',
            name: RouteNames.agentSources,
            builder: (context, state) =>
                const _RoutePlaceholder(title: 'Sources & Tradipraticiens'),
          ),
          GoRoute(
            path: 'profil',
            name: RouteNames.agentProfil,
            builder: (context, state) =>
                const _RoutePlaceholder(title: 'Profil Agent'),
          ),
        ],
      ),

      // 6. Espace Officine Pharmacopée (US-18 à US-24)
      GoRoute(
        path: RouteNames.pharmacopeeDashboardPath,
        name: RouteNames.pharmacopeeDashboard,
        builder: (context, state) =>
            const _RoutePlaceholder(title: 'Tableau de bord Officine'),
        routes: [
          GoRoute(
            path: 'stock',
            name: RouteNames.pharmacopeeStock,
            builder: (context, state) =>
                const _RoutePlaceholder(title: 'Gestion des Stocks'),
            routes: [
              GoRoute(
                path: 'ajouter',
                name: RouteNames.pharmacopeeAjouterProduit,
                builder: (context, state) =>
                    const _RoutePlaceholder(title: 'Ajouter Produit Stock'),
              ),
            ],
          ),
          GoRoute(
            path: 'modes-retrait',
            name: RouteNames.pharmacopeeModesRetrait,
            builder: (context, state) =>
                const _RoutePlaceholder(title: 'Configuration Modes Retrait'),
          ),
          GoRoute(
            path: 'commandes',
            name: RouteNames.pharmacopeeCommandes,
            builder: (context, state) =>
                const _RoutePlaceholder(title: 'Commandes Clients Reçues'),
            routes: [
              GoRoute(
                path: ':id',
                name: RouteNames.pharmacopeeCommandeDetail,
                builder: (context, state) => _RoutePlaceholder(
                  title:
                      'Détail Commande Officine (${state.pathParameters['id']})',
                ),
                routes: [
                  GoRoute(
                    path: 'valider-pickup',
                    name: RouteNames.pharmacopeeValiderPickup,
                    builder: (context, state) => _RoutePlaceholder(
                      title:
                          'Validation Retrait (${state.pathParameters['id']})',
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: 'avis',
            name: RouteNames.pharmacopeeAvis,
            builder: (context, state) =>
                const _RoutePlaceholder(title: 'Avis Clients Officine'),
          ),
          GoRoute(
            path: 'profil',
            name: RouteNames.pharmacopeeProfil,
            builder: (context, state) =>
                const _RoutePlaceholder(title: 'Profil Officine'),
          ),
          GoRoute(
            path: 'referencement',
            name: RouteNames.pharmacopeeReferencement,
            builder: (context, state) =>
                const _RoutePlaceholder(title: 'Demande Agrément INRMPT'),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Introuvable')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              'Route non trouvée : ${state.matchedLocation}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(RouteNames.visitorHomePath),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Widget temporaire utilisé comme placeholder pour les routes avant intégration des écrans features.
class _RoutePlaceholder extends StatelessWidget {
  final String title;
  const _RoutePlaceholder({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
