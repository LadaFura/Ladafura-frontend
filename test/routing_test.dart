import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ladafura_frontend_flutter/core/routing/routing.dart';
import 'package:ladafura_frontend_flutter/shared/enums/user_role.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Routing Layer Tests - LADAFURA (Périmètre 2 Rôles)', () {
    test('RouteNames defines standardized URLs and path generators', () {
      expect(RouteNames.splashPath, '/');
      expect(RouteNames.loginPath, '/auth/login');
      expect(RouteNames.registerPath, '/auth/register');
      expect(RouteNames.visitorHomePath, '/visitor');
      expect(RouteNames.visitorRecherchePath, '/visitor/recherche');
      expect(RouteNames.citizenHomePath, '/citizen');
      expect(RouteNames.citizenRecherchePath, '/citizen/recherche');
      expect(RouteNames.citizenFavorisPath, '/citizen/favoris');
      expect(RouteNames.citizenPanierPath, '/citizen/panier');
      expect(RouteNames.citizenCartePath, '/citizen/carte');
      expect(RouteNames.agentDashboardPath, '/agent');
      expect(RouteNames.agentCollectesPath, '/agent/collectes');

      // Helper URLs paramétrés
      expect(
        RouteNames.visitorPlanteDetailUrl('101'),
        '/visitor/plantes/101',
      );
      expect(
        RouteNames.citizenPlanteDetailUrl('101'),
        '/citizen/plantes/101',
      );
      expect(
        RouteNames.agentCollecteDetailUrl('col-99'),
        '/agent/collectes/col-99',
      );
    });

    group('RouteGuard Decision Tree Tests (Citoyen & Agent de Collecte)', () {
      test('Redirection pendant la phase d\'initialisation (Splash)', () {
        final redirect1 = RouteGuard.evaluateRedirect(
          currentPath: '/citizen',
          isAuthenticated: false,
          role: null,
          isInitializing: true,
        );
        expect(redirect1, RouteNames.splashPath);

        final redirect2 = RouteGuard.evaluateRedirect(
          currentPath: RouteNames.splashPath,
          isAuthenticated: false,
          role: null,
          isInitializing: true,
        );
        expect(redirect2, isNull);
      });

      test('Utilisateur sans session : Splash -> Espace Visiteur', () {
        final redirect = RouteGuard.evaluateRedirect(
          currentPath: RouteNames.splashPath,
          isAuthenticated: false,
          role: null,
          isInitializing: false,
        );
        expect(redirect, RouteNames.visitorHomePath);
      });

      test(
          'Utilisateur sans session : Accès libre aux routes publiques et auth',
          () {
        final publicPaths = [
          RouteNames.visitorHomePath,
          RouteNames.visitorRecherchePath,
          RouteNames.loginPath,
          RouteNames.registerPath,
          RouteNames.onboardingPath,
          RouteNames.roleSelectionPath,
        ];

        for (final path in publicPaths) {
          final redirect = RouteGuard.evaluateRedirect(
            currentPath: path,
            isAuthenticated: false,
            role: null,
            isInitializing: false,
          );
          expect(redirect, isNull,
              reason: 'La route $path doit être libre d\'accès');
        }
      });

      test(
          'Utilisateur sans session : Tentative d\'accès à un espace privé -> Redirection Login',
          () {
        final protectedPaths = [
          RouteNames.citizenHomePath,
          RouteNames.citizenCartePath,
          RouteNames.citizenFavorisPath,
          RouteNames.citizenPanierPath,
          RouteNames.citizenProfilPath,
          RouteNames.agentDashboardPath,
          RouteNames.agentCollectesPath,
          RouteNames.agentNouvelleCollectePath,
          RouteNames.visitorPanierPath,
          RouteNames.visitorProfilPath,
        ];

        for (final path in protectedPaths) {
          final redirect = RouteGuard.evaluateRedirect(
            currentPath: path,
            isAuthenticated: false,
            role: null,
            isInitializing: false,
          );
          expect(
            redirect,
            RouteNames.loginPath,
            reason:
                'La route $path doit renvoyer vers login pour un visiteur anonyme',
          );
        }
      });

      test('Utilisateur POPULATION : Redirigé vers Espace Citoyen et cloisonné',
          () {
        // Redirection depuis Splash ou Login
        final fromSplash = RouteGuard.evaluateRedirect(
          currentPath: RouteNames.splashPath,
          isAuthenticated: true,
          role: UserRole.population,
        );
        expect(fromSplash, RouteNames.citizenHomePath);

        final fromLogin = RouteGuard.evaluateRedirect(
          currentPath: RouteNames.loginPath,
          isAuthenticated: true,
          role: UserRole.population,
        );
        expect(fromLogin, RouteNames.citizenHomePath);

        // Tentative d'intrusion dans l'espace Agent
        final intrusionAgent = RouteGuard.evaluateRedirect(
          currentPath: RouteNames.agentDashboardPath,
          isAuthenticated: true,
          role: UserRole.population,
        );
        expect(intrusionAgent, RouteNames.citizenHomePath);

        // Navigation légitime dans l'espace Citoyen
        final legitimeCitizen = RouteGuard.evaluateRedirect(
          currentPath: RouteNames.citizenFavorisPath,
          isAuthenticated: true,
          role: UserRole.population,
        );
        expect(legitimeCitizen, isNull);
      });

      test(
          'Utilisateur AGENT_COLLECTE : Redirigé vers Espace Agent et cloisonné',
          () {
        // Redirection depuis Splash ou Login
        final fromLogin = RouteGuard.evaluateRedirect(
          currentPath: RouteNames.loginPath,
          isAuthenticated: true,
          role: UserRole.agentCollecte,
        );
        expect(fromLogin, RouteNames.agentDashboardPath);

        // Tentative d'accès à l'espace Citoyen
        final intrusionCitizen = RouteGuard.evaluateRedirect(
          currentPath: RouteNames.citizenHomePath,
          isAuthenticated: true,
          role: UserRole.agentCollecte,
        );
        expect(intrusionCitizen, RouteNames.agentDashboardPath);

        // Navigation légitime dans l'espace Agent
        final legitimeAgent = RouteGuard.evaluateRedirect(
          currentPath: RouteNames.agentCollectesPath,
          isAuthenticated: true,
          role: UserRole.agentCollecte,
        );
        expect(legitimeAgent, isNull);
      });
    });

    test('GoRouter instance is correctly provided via Riverpod', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final router = container.read(appRouterProvider);
      expect(router, isA<GoRouter>());
      expect(router.configuration.routes.isNotEmpty, isTrue);
    });

    test(
        'Pages secondaires (détails, commandes, favoris) hors du ShellRoute sans BottomNavBar',
        () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final router = container.read(appRouterProvider);
      final routes = router.configuration.routes;

      // 1. Les ShellRoutes ne doivent contenir QUE les 5 onglets principaux
      final shellRoutes = routes.whereType<ShellRoute>().toList();
      expect(shellRoutes.isNotEmpty, isTrue);

      for (final shell in shellRoutes) {
        final tabNames =
            shell.routes.whereType<GoRoute>().map((r) => r.name).toList();
        expect(tabNames.contains(RouteNames.citizenPlanteDetail), isFalse);
        expect(tabNames.contains(RouteNames.citizenPharmacopeeDetail), isFalse);
        expect(tabNames.contains(RouteNames.citizenCommandes), isFalse);
        expect(tabNames.contains(RouteNames.citizenFavoris), isFalse);
        expect(tabNames.contains(RouteNames.visitorPlanteDetail), isFalse);
        expect(tabNames.contains(RouteNames.visitorPharmacopeeDetail), isFalse);
      }

      // 2. Les pages secondaires doivent être au niveau racine avec parentNavigatorKey = rootNavigatorKey
      final rootGoRoutes = routes.whereType<GoRoute>().toList();
      final detailRoutes = rootGoRoutes.where((r) => [
            RouteNames.citizenPlanteDetail,
            RouteNames.citizenPharmacopeeDetail,
            RouteNames.citizenCommandes,
            RouteNames.citizenFavoris,
            RouteNames.visitorPlanteDetail,
            RouteNames.visitorPharmacopeeDetail,
          ].contains(r.name));

      expect(detailRoutes.length, 6);
      for (final route in detailRoutes) {
        expect(route.parentNavigatorKey, rootNavigatorKey);
      }
    });
  });
}

