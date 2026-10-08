import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../models/profil_model.dart';

/// Carte utilisateur moderne en en-tête inspirée de la référence visuelle :
/// - Avatar circulaire élégant avec initiales
/// - Nom complet en gras avec typographie officielle
/// - Email ou téléphone avec texte secondaire officiel
/// - Bouton d'action "Modifier mon profil"
class ModernProfileUserCard extends StatelessWidget {
  final ProfilModel? profil;
  final VoidCallback onEditProfile;

  const ModernProfileUserCard({
    super.key,
    required this.profil,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;

    final nomComplet = profil?.nomComplet.isNotEmpty == true
        ? profil!.nomComplet
        : 'Utilisateur LADAFURA';
    final email = profil?.email ?? (profil?.telephone ?? 'Compte Citoyen');

    return Container(
      width: double.infinity,
      padding: AppDimensions.paddingCard,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusModal),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
          width: AppDimensions.cardBorderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 20 : 6),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar circulaire
          Container(
            width: AppDimensions.avatarLarge,
            height: AppDimensions.avatarLarge,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withAlpha(25),
              border: Border.all(
                color: primaryColor.withAlpha(50),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                profil?.initiales ?? 'U',
                style: (isDark ? AppTextStyles.h2Dark : AppTextStyles.h2).copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.space16),

          // Informations utilisateur
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nomComplet,
                  style: isDark ? AppTextStyles.h4Dark : AppTextStyles.h4,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.space4),
                Text(
                  email,
                  style: isDark
                      ? AppTextStyles.bodySecondaryDark
                      : AppTextStyles.bodySecondary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.space8),
                InkWell(
                  onTap: onEditProfile,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.space2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: AppDimensions.iconSizeSmall,
                          color: primaryColor,
                        ),
                        const SizedBox(width: AppDimensions.space4),
                        Text(
                          'Modifier mon profil',
                          style: AppTextStyles.label.copyWith(
                            fontSize: 13,
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
