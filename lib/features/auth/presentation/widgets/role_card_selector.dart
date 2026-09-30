import 'package:flutter/material.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_text_styles.dart';
import 'package:ladafura_frontend_flutter/shared/enums/user_role.dart';

/// Carte sélectionnable pour choisir l'espace mobile souhaité.
class RoleCardSelector extends StatelessWidget {
  final UserRole selectedRole;
  final ValueChanged<UserRole> onRoleSelected;

  const RoleCardSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRoleTile(
          context: context,
          role: UserRole.population,
          title: 'Citoyen / Population',
          subtitle:
              'Consultez les plantes médicinales, remèdes traditionnels et commandez en officine.',
          icon: Icons.person_outline,
          accentColor: AppColors.primary,
        ),
        const SizedBox(height: AppDimensions.space12),
        _buildRoleTile(
          context: context,
          role: UserRole.agentCollecte,
          title: 'Agent de Collecte',
          subtitle:
              'Enregistrez les récits oraux des tradithérapeutes et géolocalisez les espèces végétales.',
          icon: Icons.edit_location_alt_outlined,
          accentColor: AppColors.accent,
        ),
        const SizedBox(height: AppDimensions.space12),
        _buildRoleTile(
          context: context,
          role: UserRole.pharmacopee,
          title: 'Officine / Pharmacopée',
          subtitle:
              'Gérez votre officine, mettez à jour vos stocks de remèdes et traitez les commandes.',
          icon: Icons.storefront_outlined,
          accentColor: AppColors.info,
        ),
      ],
    );
  }

  Widget _buildRoleTile({
    required BuildContext context,
    required UserRole role,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = selectedRole == role;

    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final borderColor = isSelected
        ? primaryColor
        : (isDark ? AppColors.darkBorder : AppColors.border);
    final bgColor = isSelected
        ? (isDark
            ? AppColors.darkPrimaryContainer
            : AppColors.badgeTraditionnelBg)
        : (isDark ? AppColors.darkSurface : AppColors.surface);

    return InkWell(
      onTap: () => onRoleSelected(role),
      borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.space16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.space12),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor
                    : (isDark
                        ? AppColors.darkBorder
                        : accentColor.withValues(alpha: 0.12)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? (isDark ? AppColors.darkBackground : Colors.white)
                    : accentColor,
                size: 24,
              ),
            ),
            const SizedBox(width: AppDimensions.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style:
                              (isDark ? AppTextStyles.h4Dark : AppTextStyles.h4)
                                  .copyWith(
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w600,
                            color: isSelected && !isDark
                                ? AppColors.primaryDark
                                : null,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: primaryColor,
                          size: 20,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: (isDark
                            ? AppTextStyles.bodySecondaryDark
                            : AppTextStyles.bodySecondary)
                        .copyWith(
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.textMuted,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
