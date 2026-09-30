import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ladafura_frontend_flutter/core/routing/route_names.dart';
import 'package:ladafura_frontend_flutter/features/auth/providers/auth_state_provider.dart';
import 'package:ladafura_frontend_flutter/shared/enums/user_role.dart';
import 'ladafura_bottom_nav_bar.dart';

/// Shell principal intégrant la barre de navigation officielle LADAFURA à 5 onglets.
class AppShell extends ConsumerWidget {
  final String? location;
  final Widget child;

  const AppShell({super.key, this.location, required this.child});

  void _onTabTapped(BuildContext context, WidgetRef ref, int index) {
    ref.read(navigationIndexProvider.notifier).setIndex(index);
    final authState = ref.read(authStateProvider);
    final isCitizen =
        authState.isAuthenticated && authState.role == UserRole.population;
    final isAgent =
        authState.isAuthenticated && authState.role == UserRole.agentCollecte;

    if (isAgent) {
      // Pour l'agent de collecte
      switch (index) {
        case 0:
          context.go(RouteNames.agentDashboardPath);
          break;
        case 1:
          context.go(RouteNames.agentCollectesPath);
          break;
        case 2:
          context.go(RouteNames.agentSourcesPath);
          break;
        case 3:
        case 4:
          context.go(RouteNames.agentProfilPath);
          break;
      }
      return;
    }

    if (isCitizen) {
      // Pour le citoyen connecté
      switch (index) {
        case 0:
          context.go(RouteNames.citizenHomePath);
          break;
        case 1:
          context.go(RouteNames.citizenRecherchePath);
          break;
        case 2:
          context.go(RouteNames.citizenCartePath);
          break;
        case 3:
          context.go(RouteNames.citizenFavorisPath);
          break;
        case 4:
          context.go(RouteNames.citizenProfilPath);
          break;
      }
      return;
    }

    // Mode Visiteur (non connecté)
    switch (index) {
      case 0:
        context.go(RouteNames.visitorHomePath);
        break;
      case 1:
        context.go(RouteNames.visitorRecherchePath);
        break;
      case 2:
        context.go(RouteNames.visitorCartePath);
        break;
      case 3:
        // Panier protégé : RouteGuard redirigera vers /auth/login si non authentifié
        context.go(RouteNames.visitorPanierPath);
        break;
      case 4:
        // Profil protégé : RouteGuard redirigera vers /auth/login si non authentifié
        context.go(RouteNames.visitorProfilPath);
        break;
    }
  }

  int _calculateIndexFromLocation(String location) {
    if (location.startsWith(RouteNames.visitorRecherchePath) ||
        location.startsWith(RouteNames.citizenRecherchePath) ||
        location.startsWith(RouteNames.agentCollectesPath)) {
      return 1;
    }

    if (location.startsWith(RouteNames.visitorCartePath) ||
        location.startsWith(RouteNames.citizenCartePath) ||
        location.startsWith(RouteNames.agentSourcesPath)) {
      return 2;
    }

    if (location.startsWith(RouteNames.visitorPanierPath) ||
        location.startsWith(RouteNames.citizenFavorisPath)) {
      return 3;
    }

    if (location.startsWith(RouteNames.visitorProfilPath) ||
        location.startsWith(RouteNames.citizenProfilPath) ||
        location.startsWith(RouteNames.agentProfilPath)) {
      return 4;
    }

    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeIndex = (location != null && location!.isNotEmpty)
        ? _calculateIndexFromLocation(location!)
        : ref.watch(navigationIndexProvider);

    return PopScope(
      canPop: activeIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (activeIndex != 0) {
          _onTabTapped(context, ref, 0);
        }
      },
      child: Scaffold(
        extendBody: true,
        body: child,
        bottomNavigationBar: LadafuraBottomNavBar(
          currentIndex: activeIndex,
          onTap: (index) => _onTabTapped(context, ref, index),
        ),
      ),
    );
  }
}
