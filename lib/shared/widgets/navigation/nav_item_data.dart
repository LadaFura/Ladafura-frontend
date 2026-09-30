import 'package:flutter/material.dart';

/// Modèle de données décrivant un onglet de la barre de navigation LADAFURA
class NavItemData {
  /// Identifiant d'index unique (0 à 4)
  final int index;

  /// Libellé textuel affiché lors de la sélection (ex: 'Accueil', 'Recherche')
  final String label;

  /// Icône affichée lorsque l'onglet est actif
  final IconData activeIcon;

  /// Icône affichée lorsque l'onglet est inactif
  final IconData inactiveIcon;

  /// Infobulle d'accessibilité au survol ou appui long
  final String tooltip;

  /// Nombre d'éléments à notifier (ex: quantité du panier)
  final int badgeCount;

  const NavItemData({
    required this.index,
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.tooltip,
    this.badgeCount = 0,
  });

  /// Liste officielle des 5 onglets de la plateforme LADAFURA (Population & Agent)
  static List<NavItemData> defaultItems({int badgeCount = 0, int? cartBadgeCount}) => [
        const NavItemData(
          index: 0,
          label: 'Accueil',
          activeIcon: Icons.home_rounded,
          inactiveIcon: Icons.home_outlined,
          tooltip: 'Accueil',
        ),
        const NavItemData(
          index: 1,
          label: 'Flore',
          activeIcon: Icons.eco_rounded,
          inactiveIcon: Icons.eco_outlined,
          tooltip: 'Flore & Plantes Médicinales',
        ),
        const NavItemData(
          index: 2,
          label: 'Recherche',
          activeIcon: Icons.search_rounded,
          inactiveIcon: Icons.search_rounded,
          tooltip: 'Recherche',
        ),
        NavItemData(
          index: 3,
          label: 'Favoris',
          activeIcon: Icons.bookmark_rounded,
          inactiveIcon: Icons.bookmark_border_rounded,
          tooltip: 'Favoris',
          badgeCount: cartBadgeCount ?? badgeCount,
        ),
        const NavItemData(
          index: 4,
          label: 'Profil',
          activeIcon: Icons.person_rounded,
          inactiveIcon: Icons.person_outline_rounded,
          tooltip: 'Profil',
        ),
      ];
}
