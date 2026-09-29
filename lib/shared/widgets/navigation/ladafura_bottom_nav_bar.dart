import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

/// Barre de navigation flottante moderne officielle de LADAFURA.
///
/// Reproduit fidèlement le design flottant composé de :
/// - 4 boutons circulaires (Accueil, Carte, Panier, Profil)
/// - 1 bouton capsule central étendu (« Recherche »)
///
/// Compatible nativement Thème Clair et Thème Sombre, avec micro-animations
/// de pression tactile et support optionnel d'un badge sur le panier.
class LadafuraBottomNavBar extends StatelessWidget {
  /// Index de l'onglet actuellement sélectionné (0 à 4)
  final int currentIndex;

  /// Callback déclenché lors du clic sur un onglet
  final ValueChanged<int> onTap;

  /// Nombre d'articles dans le panier (affiche un badge si > 0)
  final int cartBadgeCount;

  const LadafuraBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.cartBadgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          children: [
            // 0 : Accueil (Bouton circulaire)
            _NavCircleButton(
              index: 0,
              selectedIndex: currentIndex,
              activeIcon: Icons.home_rounded,
              inactiveIcon: Icons.home_outlined,
              tooltip: 'Accueil',
              onTap: () => onTap(0),
              isDark: isDark,
            ),

            // 1 : Carte / Géolocalisation (Bouton circulaire)
            _NavCircleButton(
              index: 1,
              selectedIndex: currentIndex,
              activeIcon: Icons.map_rounded,
              inactiveIcon: Icons.map_outlined,
              tooltip: 'Carte des tradipraticiens & officines',
              onTap: () => onTap(1),
              isDark: isDark,
            ),

            // 2 : Recherche (Bouton capsule central)
            _NavSearchCapsule(
              isSelected: currentIndex == 2,
              onTap: () => onTap(2),
              isDark: isDark,
            ),

            // 3 : Panier (Bouton circulaire avec badge optionnel)
            _NavCircleButton(
              index: 3,
              selectedIndex: currentIndex,
              activeIcon: Icons.shopping_cart_rounded,
              inactiveIcon: Icons.shopping_cart_outlined,
              tooltip: 'Panier',
              badgeCount: cartBadgeCount,
              onTap: () => onTap(3),
              isDark: isDark,
            ),

            // 4 : Profil / Compte (Bouton circulaire)
            _NavCircleButton(
              index: 4,
              selectedIndex: currentIndex,
              activeIcon: Icons.person_rounded,
              inactiveIcon: Icons.person_outline_rounded,
              tooltip: 'Profil',
              onTap: () => onTap(4),
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}

/// Bouton de navigation circulaire avec micro-interaction et ombre douce
class _NavCircleButton extends StatefulWidget {
  final int index;
  final int selectedIndex;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isDark;
  final int badgeCount;

  const _NavCircleButton({
    required this.index,
    required this.selectedIndex,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.tooltip,
    required this.onTap,
    required this.isDark,
    this.badgeCount = 0,
  });

  @override
  State<_NavCircleButton> createState() => _NavCircleButtonState();
}

class _NavCircleButtonState extends State<_NavCircleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.index == widget.selectedIndex;

    // Couleurs adaptées Clair / Sombre
    final Color backgroundColor = widget.isDark
        ? (isSelected ? AppColors.darkPrimaryContainer : AppColors.darkSurface)
        : Colors.white;

    final Color iconColor = widget.isDark
        ? (isSelected ? AppColors.darkPrimary : AppColors.darkTextSecondary)
        : (isSelected ? AppColors.textPrimary : AppColors.textSecondary);

    final Color borderColor = widget.isDark
        ? (isSelected
            ? AppColors.darkPrimary.withValues(alpha: 0.5)
            : AppColors.darkBorder)
        : (isSelected
            ? Colors.black.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.04));

    final List<BoxShadow> shadows = widget.isDark
        ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
            if (isSelected)
              BoxShadow(
                color: AppColors.darkPrimary.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
            if (isSelected)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ];

    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _isPressed ? 0.90 : (isSelected ? 1.05 : 1.0),
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: AppDimensions.navBarCircleSize,
                height: AppDimensions.navBarCircleSize,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 1.0),
                  boxShadow: shadows,
                ),
                child: Center(
                  child: Icon(
                    isSelected ? widget.activeIcon : widget.inactiveIcon,
                    color: iconColor,
                    size: AppDimensions.navBarIconSize,
                  ),
                ),
              ),

              // Badge de notification / panier
              if (widget.badgeCount > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.isDark
                            ? AppColors.darkSurface
                            : Colors.white,
                        width: 1.5,
                      ),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: AppDimensions.cartBadgeSize,
                      minHeight: AppDimensions.cartBadgeSize,
                    ),
                    child: Center(
                      child: Text(
                        widget.badgeCount > 99 ? '99+' : '${widget.badgeCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bouton capsule central « Recherche » avec icône et label
class _NavSearchCapsule extends StatefulWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _NavSearchCapsule({
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  State<_NavSearchCapsule> createState() => _NavSearchCapsuleState();
}

class _NavSearchCapsuleState extends State<_NavSearchCapsule> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = widget.isDark
        ? (widget.isSelected
            ? AppColors.darkPrimaryContainer
            : AppColors.darkSurface)
        : (widget.isSelected
            ? AppColors.primaryLight.withValues(alpha: 0.6)
            : Colors.white);

    final Color contentColor = widget.isDark
        ? (widget.isSelected
            ? AppColors.darkPrimary
            : AppColors.darkTextSecondary)
        : (widget.isSelected ? AppColors.primaryDark : const Color(0xFF475569));

    final Color borderColor = widget.isDark
        ? (widget.isSelected
            ? AppColors.darkPrimary.withValues(alpha: 0.6)
            : AppColors.darkBorder)
        : (widget.isSelected
            ? AppColors.primary.withValues(alpha: 0.3)
            : Colors.black.withValues(alpha: 0.05));

    final List<BoxShadow> shadows = widget.isDark
        ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
            if (widget.isSelected)
              BoxShadow(
                color: AppColors.darkPrimary.withValues(alpha: 0.2),
                blurRadius: 14,
                offset: const Offset(0, 2),
              ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ];

    return Tooltip(
      message: 'Rechercher une plante ou un remède',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _isPressed ? 0.94 : (widget.isSelected ? 1.03 : 1.0),
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: AppDimensions.navBarCapsuleHeight,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space16,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(AppDimensions.radiusBadge),
              border: Border.all(color: borderColor, width: 1.0),
              boxShadow: shadows,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search_rounded,
                  color: contentColor,
                  size: 21,
                ),
                const SizedBox(width: AppDimensions.space8),
                Text(
                  'Recherche',
                  style: (widget.isDark
                          ? AppTextStyles.labelDark
                          : AppTextStyles.label)
                      .copyWith(
                    color: contentColor,
                    fontSize: 14,
                    fontWeight:
                        widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
