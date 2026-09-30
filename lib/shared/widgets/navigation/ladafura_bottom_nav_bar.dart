import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_dimensions.dart';
import 'nav_button.dart';
import 'nav_item_data.dart';
import 'navigation_provider.dart';

export 'nav_badge.dart';
export 'nav_button.dart';
export 'nav_item_data.dart';
export 'navigation_provider.dart';

/// Barre de navigation flottante moderne officielle de LADAFURA.
///
/// Décomposée en sous-composants modulaires :
/// - [NavButton] : Bouton adaptatif avec morphing fluide cercle $\leftrightarrow$ capsule
/// - [NavBadge] : Pastille numérique de notification (ex: panier)
/// - [NavItemData] : Modèle de données des onglets
/// - [navigationIndexProvider] : Gestion d'état Riverpod de l'onglet actif
///
/// Tous les onglets partagent désormais le même effet de sélection élégant :
/// l'onglet actif s'étire en capsule avec icône + texte, tandis que les
/// onglets inactifs adoptent un format circulaire discret.
class LadafuraBottomNavBar extends ConsumerWidget {
  /// Index de l'onglet actuellement sélectionné (optionnel, utilise Riverpod par défaut)
  final int? currentIndex;

  /// Callback déclenché lors du clic sur un onglet (optionnel)
  final ValueChanged<int>? onTap;

  /// Nombre d'articles dans le panier (optionnel, utilise Riverpod par défaut)
  final int? cartBadgeCount;

  /// Liste personnalisée d'onglets (optionnel, utilise les 5 onglets par défaut)
  final List<NavItemData>? items;

  const LadafuraBottomNavBar({
    super.key,
    this.currentIndex,
    this.onTap,
    this.cartBadgeCount,
    this.items,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int activeIndex = currentIndex ?? ref.watch(navigationIndexProvider);
    final int badgeCount = cartBadgeCount ?? ref.watch(cartBadgeCountProvider);

    final navItems =
        items ?? NavItemData.defaultItems(cartBadgeCount: badgeCount);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppDimensions.space16,
          right: AppDimensions.space16,
          bottom: AppDimensions.space12,
          top: AppDimensions.space8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: navItems.map((item) {
            return NavButton(
              key: ValueKey('nav_item_${item.index}'),
              item: item,
              isSelected: item.index == activeIndex,
              onTap: () {
                ref.read(navigationIndexProvider.notifier).setIndex(item.index);
                onTap?.call(item.index);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
