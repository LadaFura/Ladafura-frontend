import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Pastille de notification numérique pour la barre de navigation
class NavBadge extends StatelessWidget {
  final int count;
  final bool isDark;

  const NavBadge({
    super.key,
    required this.count,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    final label = count > 99 ? '99+' : '$count';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.danger,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? AppColors.darkSurface : Colors.white,
          width: 1.5,
        ),
      ),
      constraints: const BoxConstraints(
        minWidth: AppDimensions.cartBadgeSize,
        minHeight: AppDimensions.cartBadgeSize,
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
