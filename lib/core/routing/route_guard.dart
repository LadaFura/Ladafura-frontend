import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../../shared/enums/user_role.dart';
import 'route_names.dart';

/// Garde de navigation (RouteGuard) centralisé pour LADAFURA Mobile.
///
/// Implémente rigoureusement l'organigramme décisionnel du parcours utilisateur :
/// 1. Splash : initialisation et contrôle d'état de session.
/// 2. Session absente (Mode Visiteur) :
///    - Accès libre aux routes publiques (`/visitor/**`).
///    - Redirection vers `/auth/login` si l'utilisateur tente d'accéder à un espace réservé.
/// 3. Session présente :
///    - Rôle [UserRole.population] -> Espace Citoyen (`/citizen/**`).
///    - Rôle [UserRole.agentCollecte] -> Espace Agent de Collecte (`/agent/**`).
///    - Cloisonnement strict : un citoyen ne peut pas accéder aux routes de l'agent et inversement.
class RouteGuard {
  RouteGuard._();

  /// Évalue la destination de redirection de manière pure et déterministe (testable unitairement).
  static String? evaluateRedirect({
    required String currentPath,
    required bool isAuthenticated,
    required UserRole? role,
    bool isInitializing = false,
  }) {
    // 1. Phase d'initialisation (Splash Screen)
    if (isInitializing) {
      return currentPath == RouteNames.splashPath
          ? null
          : RouteNames.splashPath;
    }

    final isSplash = currentPath == RouteNames.splashPath;
    final isAuthRoute = currentPath.startsWith('/auth') ||
        currentPath == RouteNames.onboardingPath;
    final isVisitorRoute = currentPath.startsWith('/visitor');
    final isCitizenRoute = currentPath.startsWith('/citizen');
    final isAgentRoute = currentPath.startsWith('/agent');

    // 2. Utilisateur NON authentifié (Visiteur)
    if (!isAuthenticated) {
      if (isSplash) {
        // Laisser SplashScreen gérer la vérification d'onboarding et la redirection fluide
        return null;
      }

      // Si le visiteur tente d'accéder à un espace nécessitant un compte
      final isProtectedVisitorRoute =
          currentPath.startsWith(RouteNames.visitorPanierPath) ||
              currentPath.startsWith(RouteNames.visitorProfilPath);

      if (isCitizenRoute || isAgentRoute || isProtectedVisitorRoute) {
        return RouteNames.loginPath;
      }

      // Libre accès aux pages publiques et écrans d'authentification
      return null;
    }

    // 3. Utilisateur AUTHENTIFIÉ
    // Si l'utilisateur connecté est sur Splash, Auth ou Visiteur, le rediriger vers son espace dédié
    if (isSplash || isAuthRoute || isVisitorRoute) {
      return _getDefaultHomeForRole(role);
    }

    // Vérification du cloisonnement des 2 rôles
    switch (role) {
      case UserRole.population:
        if (isAgentRoute) {
          return RouteNames.citizenHomePath;
        }
        break;

      case UserRole.agentCollecte:
        if (isCitizenRoute) {
          return RouteNames.agentDashboardPath;
        }
        break;

      default:
        return RouteNames.loginPath;
    }

    // Aucune redirection nécessaire
    return null;
  }

  /// Détermine la page d'accueil par défaut selon le rôle de l'utilisateur.
  static String _getDefaultHomeForRole(UserRole? role) {
    switch (role) {
      case UserRole.population:
        return RouteNames.citizenHomePath;
      case UserRole.agentCollecte:
        return RouteNames.agentDashboardPath;
      default:
        return RouteNames.visitorHomePath;
    }
  }

  /// Helper pour intégration directe dans la configuration [GoRouter.redirect].
  static String? guardRedirect({
    required BuildContext context,
    required GoRouterState state,
    required bool isAuthenticated,
    required UserRole? role,
    bool isInitializing = false,
  }) {
    return evaluateRedirect(
      currentPath: state.matchedLocation,
      isAuthenticated: isAuthenticated,
      role: role,
      isInitializing: isInitializing,
    );
  }
}
