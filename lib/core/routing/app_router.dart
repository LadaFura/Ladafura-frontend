import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/agent/presentation/dashboard/screens/agent_dashboard_screen.dart';
import '../../features/auth/auth.dart';
import '../../features/home/presentation/pages/citizen_home_screen.dart';
import '../../features/recherche/presentation/pages/citizen_search_screen.dart';
import '../../features/home/presentation/pages/accueil_screen.dart';
import '../../features/carte/presentation/pages/carte_screen.dart';
import '../../features/panier/presentation/pages/panier_screen.dart';
import '../../features/profil/presentation/pages/profil_screen.dart';
import '../../features/profil/presentation/pages/modifier_profil_screen.dart';
import '../../features/profil/presentation/pages/parametres_screen.dart';
import '../../features/plantes/presentation/pages/plante_detail_page.dart';
import '../../features/commandes/presentation/pages/commandes_screen.dart';
import '../../features/commandes/presentation/pages/commande_validation_screen.dart';
import '../../features/commandes/presentation/pages/commande_paiement_screen.dart';
import '../../features/commandes/presentation/pages/commande_confirmation_screen.dart';
import '../../features/commandes/presentation/pages/commande_detail_page.dart';
import '../../features/commandes/models/commande_model.dart';
import '../../features/commandes/models/paiement_model.dart';
import '../../features/pharmacopees/presentation/pages/pharmacopee_detail_page.dart';
import '../../shared/enums/user_role.dart';
import '../../shared/widgets/navigation/app_shell.dart';
import '../../shared/widgets/navigation/navigation_provider.dart';
import '../services/services_providers.dart';
import 'route_guard.dart';
import 'route_names.dart';

part 'app_router.g.dart';

/// Clé globale de navigation permettant la navigation sans contexte si nécessaire.
final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'rootNavigator');

final GlobalKey<NavigatorState> visitorShellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'visitorShellNavigator');
final GlobalKey<NavigatorState> citizenShellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'citizenShellNavigator');

/// Modèle d'état d'authentification pour le routeur.
class AuthRoutingState extends ChangeNotifier {
  bool _isAuthenticated = false;
  UserRole? _role;
  bool _isInitializing = false;

  AuthRoutingState({
    bool isAuthenticated = false,
    UserRole? role,
    bool isInitializing = false,
  })  : _isAuthenticated = isAuthenticated,
        _role = role,
        _isInitializing = isInitializing;

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
      _safeNotifyListeners();
    }
  }

  void _safeNotifyListeners() {
    final binding = WidgetsBinding.instance;
    if (binding.schedulerPhase == SchedulerPhase.persistentCallbacks ||
        binding.schedulerPhase == SchedulerPhase.midFrameMicrotasks) {
      binding.addPostFrameCallback((_) {
        notifyListeners();
      });
    } else {
      notifyListeners();
    }
  }
}

/// Fournisseur Riverpod de l'état d'authentification pour la navigation.
@Riverpod(keepAlive: true)
AuthRoutingState authRoutingState(AuthRoutingStateRef ref) {
  bool isAuthenticated = false;
  UserRole? role;

  try {
    final storage = ref.watch(storageServiceProvider);
    final token = storage.getToken();
    final roleStr = storage.getRole();
    role = UserRole.fromString(roleStr);
    isAuthenticated = token != null && token.isNotEmpty && role != null;
  } catch (_) {
    // Si storageServiceProvider n'est pas configuré dans un conteneur de test isolé
  }

  return AuthRoutingState(
    isAuthenticated: isAuthenticated,
    role: role,
    isInitializing: false,
  );
}

/// Fournisseur Riverpod central du [GoRouter] adapté aux 2 acteurs mobiles (Population & Agent).
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
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.registerPath,
        name: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.roleSelectionPath,
        name: RouteNames.roleSelection,
        builder: (context, state) => const RoleSelectionScreen(),
      ),

      // 3. Espace Visiteur (Navigation principale avec barre de navigation)
      ShellRoute(
        navigatorKey: visitorShellNavigatorKey,
        builder: (context, state, child) =>
            AppShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: RouteNames.visitorHomePath,
            name: RouteNames.visitorHome,
            builder: (context, state) => const AccueilScreen(),
          ),
          GoRoute(
            path: RouteNames.visitorRecherchePath,
            name: RouteNames.visitorRecherche,
            builder: (context, state) => const CitizenSearchScreen(),
          ),
          GoRoute(
            path: RouteNames.visitorCartePath,
            name: RouteNames.visitorCarte,
            builder: (context, state) => const CarteScreen(),
          ),
          GoRoute(
            path: RouteNames.visitorPanierPath,
            name: RouteNames.visitorPanier,
            builder: (context, state) => const PanierScreen(),
          ),
          GoRoute(
            path: RouteNames.visitorProfilPath,
            name: RouteNames.visitorProfil,
            builder: (context, state) => const ProfilScreen(),
          ),
        ],
      ),

      // 4. Espace Citoyen / Population (5 Onglets principaux avec barre de navigation)
      ShellRoute(
        navigatorKey: citizenShellNavigatorKey,
        builder: (context, state, child) =>
            AppShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: RouteNames.citizenHomePath,
            name: RouteNames.citizenHome,
            builder: (context, state) => const CitizenHomeScreen(),
          ),
          GoRoute(
            path: RouteNames.citizenRecherchePath,
            name: RouteNames.citizenRecherche,
            builder: (context, state) => const CitizenSearchScreen(),
          ),
          GoRoute(
            path: RouteNames.citizenCartePath,
            name: RouteNames.citizenCarte,
            builder: (context, state) => const CarteScreen(),
          ),
          GoRoute(
            path: RouteNames.citizenPanierPath,
            name: RouteNames.citizenPanier,
            builder: (context, state) => const PanierScreen(),
          ),
          GoRoute(
            path: RouteNames.citizenProfilPath,
            name: RouteNames.citizenProfil,
            builder: (context, state) => const ProfilScreen(),
          ),
        ],
      ),

      // =======================================================================
      // PAGES SECONDAIRES CITOYEN (SANS Bottom Navigation Bar - Plein écran avec retour)
      // =======================================================================
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RouteNames.citizenPlanteDetailPath,
        name: RouteNames.citizenPlanteDetail,
        builder: (context, state) => PlanteDetailPage(
          planteId:
              int.tryParse(state.pathParameters['id'] ?? '0') ?? 0,
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RouteNames.citizenPharmacopeeDetailPath,
        name: RouteNames.citizenPharmacopeeDetail,
        builder: (context, state) => PharmacopeeDetailPage(
          pharmacopeeId:
              int.tryParse(state.pathParameters['id'] ?? '0') ?? 0,
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RouteNames.citizenCommandesPath,
        name: RouteNames.citizenCommandes,
        builder: (context, state) => const CommandesScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RouteNames.citizenCommandeValidationPath,
        name: RouteNames.citizenCommandeValidation,
        builder: (context, state) => const CommandeValidationScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RouteNames.citizenCommandePaiementPath,
        name: RouteNames.citizenCommandePaiement,
        builder: (context, state) {
          final commande = state.extra as CommandeDetailModel?;
          if (commande == null) {
            return const CommandesScreen();
          }
          return CommandePaiementScreen(commande: commande);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RouteNames.citizenCommandeConfirmationPath,
        name: RouteNames.citizenCommandeConfirmation,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final commande = extra?['commande'] as CommandeDetailModel?;
          final paiement = extra?['paiement'] as PaiementResponseModel?;
          if (commande == null || paiement == null) {
            return const CommandesScreen();
          }
          return CommandeConfirmationScreen(
            commande: commande,
            paiement: paiement,
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RouteNames.citizenCommandeDetailPath,
        name: RouteNames.citizenCommandeDetail,
        builder: (context, state) => CommandeDetailPage(
          commandeId: int.tryParse(state.pathParameters['id'] ?? '0') ?? 0,
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RouteNames.citizenFavorisPath,
        name: RouteNames.citizenFavoris,
        builder: (context, state) => const _RoutePlaceholder(
          title: 'Plantes Favorites',
          isSecondary: true,
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RouteNames.citizenPanierViewPath,
        name: RouteNames.citizenPanierView,
        builder: (context, state) => const PanierScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RouteNames.citizenModifierProfilPath,
        name: RouteNames.citizenModifierProfil,
        builder: (context, state) => const ModifierProfilScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RouteNames.citizenParametresPath,
        name: RouteNames.citizenParametres,
        builder: (context, state) => const ParametresScreen(),
      ),

      // =======================================================================
      // PAGES SECONDAIRES VISITEUR (SANS Bottom Navigation Bar - Plein écran avec retour)
      // =======================================================================
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RouteNames.visitorPlanteDetailPath,
        name: RouteNames.visitorPlanteDetail,
        builder: (context, state) => PlanteDetailPage(
          planteId: int.tryParse(state.pathParameters['id'] ?? '0') ?? 0,
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RouteNames.visitorPharmacopeeDetailPath,
        name: RouteNames.visitorPharmacopeeDetail,
        builder: (context, state) => PharmacopeeDetailPage(
          pharmacopeeId: int.tryParse(state.pathParameters['id'] ?? '0') ?? 0,
        ),
      ),

      // 5. Espace Agent de Collecte Terrain (Collectes botaniques & Récits oraux)
      GoRoute(
        path: RouteNames.agentDashboardPath,
        name: RouteNames.agentDashboard,
        builder: (context, state) => const AgentDashboardScreen(),
        routes: [
          GoRoute(
            path: 'collectes',
            name: RouteNames.agentCollectes,
            builder: (context, state) =>
                const _RoutePlaceholder(title: 'Collectes Botaniques'),
            routes: [
              GoRoute(
                path: 'nouvelle',
                name: RouteNames.agentNouvelleCollecte,
                builder: (context, state) => const _RoutePlaceholder(
                  title: 'Nouvelle Collecte Terrain',
                  isSecondary: true,
                ),
              ),
              GoRoute(
                path: ':id',
                name: RouteNames.agentCollecteDetail,
                builder: (context, state) => _RoutePlaceholder(
                  title: 'Détail Collecte (${state.pathParameters['id']})',
                  isSecondary: true,
                ),
                routes: [
                  GoRoute(
                    path: 'modifier',
                    name: RouteNames.agentModifierCollecte,
                    builder: (context, state) => _RoutePlaceholder(
                      title:
                          'Modifier Collecte (${state.pathParameters['id']})',
                      isSecondary: true,
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

/// Widget écran placeholder pour les routes avant intégration des écrans features.
typedef _RoutePlaceholder = RoutePlaceholderScreen;

class RoutePlaceholderScreen extends ConsumerWidget {
  final String title;
  final bool isSecondary;

  const RoutePlaceholderScreen({
    super.key,
    required this.title,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isProfile = title.contains('Profil');

    final auth = ref.watch(authStateProvider);
    final user = auth.user;

    void goBack() {
      if (context.canPop()) {
        context.pop();
        return;
      }
      final isCitizen =
          auth.isAuthenticated && auth.role == UserRole.population;
      final isAgent =
          auth.isAuthenticated && auth.role == UserRole.agentCollecte;

      if (title.contains('Collecte')) {
        context.go(RouteNames.agentCollectesPath);
      } else if (title.contains('Favoris')) {
        ref.read(navigationIndexProvider.notifier).setIndex(0);
        context.go(RouteNames.citizenHomePath);
      } else if (title.contains('Plante')) {
        ref.read(navigationIndexProvider.notifier).setIndex(1);
        context.go(isCitizen
            ? RouteNames.citizenRecherchePath
            : RouteNames.visitorRecherchePath);
      } else if (isAgent) {
        context.go(RouteNames.agentDashboardPath);
      } else if (isCitizen) {
        context.go(RouteNames.citizenHomePath);
      } else {
        context.go(RouteNames.visitorHomePath);
      }
    }

    Widget bodyContent;
    if (isProfile && auth.isAuthenticated) {
      final name = user != null && user.nomComplet.trim().isNotEmpty
          ? user.nomComplet
          : (auth.role == UserRole.agentCollecte
              ? 'Agent Terrain'
              : 'Citoyen LADAFURA');
      final email = user?.email ?? '';
      final roleText = auth.role == UserRole.agentCollecte
          ? 'Agent de Collecte Terrain'
          : 'Citoyen';

      bodyContent = Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor:
                    isDark ? const Color(0xFF1E3A2F) : const Color(0xFFE8F5E9),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? const Color(0xFF2ECC71)
                        : const Color(0xFF1B5E20),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              if (email.isNotEmpty)
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  roleText,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE74C3C),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Se déconnecter'),
                onPressed: () async {
                  ref.read(navigationIndexProvider.notifier).setIndex(0);
                  try {
                    context.go(RouteNames.visitorHomePath);
                  } catch (_) {}
                  await ref.read(authStateProvider.notifier).logout();
                },
              ),
            ],
          ),
        ),
      );
    } else if (isProfile && !auth.isAuthenticated) {
      bodyContent = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_circle_outlined,
                size: 72, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Vous n\'êtes pas connecté',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(RouteNames.loginPath),
              child: const Text('Se connecter'),
            ),
          ],
        ),
      );
    } else if (title.contains('Panier')) {
      bodyContent = Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 72,
                color:
                    isDark ? const Color(0xFF2ECC71) : const Color(0xFF1B5E20),
              ),
              const SizedBox(height: 16),
              const Text(
                'Votre panier est vide',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Explorez notre catalogue de plantes et remèdes traditionnels pour composer votre commande.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? const Color(0xFF2ECC71)
                      : const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.search_rounded),
                label: const Text('Découvrir la pharmacopée'),
                onPressed: () {
                  ref.read(navigationIndexProvider.notifier).setIndex(1);
                  final isCitizen =
                      auth.isAuthenticated && auth.role == UserRole.population;
                  context.go(isCitizen
                      ? RouteNames.citizenRecherchePath
                      : RouteNames.visitorRecherchePath);
                },
              ),
            ],
          ),
        ),
      );
    } else {
      bodyContent = Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    }

    final scaffold = Scaffold(
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: isSecondary,
        leading: isSecondary
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Retour',
                onPressed: goBack,
              )
            : null,
      ),
      body: bodyContent,
    );

    if (isSecondary) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          goBack();
        },
        child: scaffold,
      );
    }

    return scaffold;
  }
}
