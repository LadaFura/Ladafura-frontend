import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import 'nav_badge.dart';
import 'nav_item_data.dart';

/// Bouton individuel de la barre de navigation LADAFURA.
///
/// Comportement dynamique unifié :
/// - État inactif : Bouton circulaire compact (48 × 48 px) avec icône outline.
/// - État actif : Capsule allongée (Pill) avec icône active + libellé textuel Poppins,
///   reproduisant l'effet élégant de la maquette pour TOUS les onglets.
class NavButton extends StatefulWidget {
  final NavItemData item;
  final bool isSelected;
  final VoidCallback onTap;

  const NavButton({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<NavButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = widget.isSelected;
    final item = widget.item;

    final Color backgroundColor;
    final Color borderColor;
    final Color contentColor;
    final List<BoxShadow> shadows;

    if (isDark) {
      if (isSelected) {
        backgroundColor = AppColors.darkPrimaryContainer;
        borderColor = AppColors.darkPrimary;
        contentColor = AppColors.darkPrimary;
        shadows = [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppColors.darkPrimary.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ];
      } else {
        backgroundColor = AppColors.darkSurface;
        borderColor = AppColors.darkBorder;
        contentColor = AppColors.darkTextSecondary;
        shadows = [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ];
      }
    } else {
      if (isSelected) {
        backgroundColor = Colors.white;
        borderColor = AppColors.primary.withValues(alpha: 0.25);
        contentColor = AppColors.primary;
        shadows = [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ];
      } else {
        backgroundColor = Colors.white;
        borderColor = Colors.black.withValues(alpha: 0.05);
        contentColor = AppColors.textSecondary;
        shadows = [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ];
      }
    }

    return Tooltip(
      message: item.tooltip,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _isPressed ? 0.92 : (isSelected ? 1.02 : 1.0),
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                height: AppDimensions.navBarCircleSize,
                constraints: const BoxConstraints(
                  minWidth: AppDimensions.navBarCircleSize,
                  minHeight: AppDimensions.navBarCircleSize,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected
                      ? AppDimensions.space16
                      : AppDimensions.space12,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusBadge),
                  border: Border.all(color: borderColor, width: 1.0),
                  boxShadow: shadows,
                ),
                clipBehavior: Clip.antiAlias,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isSelected ? item.activeIcon : item.inactiveIcon,
                        color: contentColor,
                        size: AppDimensions.navBarIconSize,
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: AppDimensions.space8),
                        Text(
                          item.label,
                          style: (isDark
                                  ? AppTextStyles.labelDark
                                  : AppTextStyles.label)
                              .copyWith(
                            color: contentColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Pastille de notification sur l'onglet (ex: Panier)
              if (item.badgeCount > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: NavBadge(
                    count: item.badgeCount,
                    isDark: isDark,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
