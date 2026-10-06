import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/location_service.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../pharmacopees/models/pharmacopee_model.dart';

/// Carte inférieure rétractable affichant les détails de la pharmacopée sélectionnée sur la carte.
/// Utilise rigoureusement le Design System, les constantes et les composants partagés LADAFURA.
class CartePharmacopeeDetailCard extends StatelessWidget {
  final PharmacopeeModel pharmacopee;
  final GeoCoordinates? userCoordinates;
  final VoidCallback onViewDetail;
  final VoidCallback? onClose;

  const CartePharmacopeeDetailCard({
    super.key,
    required this.pharmacopee,
    this.userCoordinates,
    required this.onViewDetail,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final distanceStr = pharmacopee.distanceFormatee(userCoordinates);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusBottomSheet),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.space20,
            AppDimensions.space12,
            AppDimensions.space20,
            AppDimensions.space16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Poignée de glissement (drag handle)
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : const Color(0xFFD6D6D6),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.space16),

              // En-tête : Icône feuille dans cercle clair, Titre & Favori
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge rond vert feuille
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkPrimaryContainer
                          : AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.eco_rounded,
                        color: isDark ? AppColors.darkPrimary : AppColors.primaryDark,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space12),

                  // Nom & Localisation
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pharmacopee.nom,
                          style: (isDark ? AppTextStyles.h4Dark : AppTextStyles.h4)
                              .copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppDimensions.space4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 15,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppDimensions.space2),
                            Flexible(
                              child: Text(
                                pharmacopee.adresseComplete,
                                style: isDark
                                    ? AppTextStyles.captionDark
                                    : AppTextStyles.caption,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.space4),
                            Text(
                              '• $distanceStr',
                              style: (isDark
                                      ? AppTextStyles.captionDark
                                      : AppTextStyles.caption)
                                  .copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkPrimary
                                    : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Bouton favori
                  IconButton(
                    icon: Icon(
                      Icons.favorite_border_rounded,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.textMuted,
                      size: 24,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${pharmacopee.nom} ajoutée aux favoris'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space12),

              // Motif de correspondance contextuel (Maladie recherchée, Produit spécifique, etc.)
              if (pharmacopee.motifCorrespondance != null &&
                  pharmacopee.motifCorrespondance!.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space12,
                    vertical: AppDimensions.space8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkPrimaryContainer.withValues(alpha: 0.4)
                        : const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkPrimary.withValues(alpha: 0.3)
                          : const Color(0xFFA5D6A7),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        size: 15,
                        color: isDark ? AppColors.darkPrimary : AppColors.primary,
                      ),
                      const SizedBox(width: AppDimensions.space8),
                      Expanded(
                        child: Text(
                          pharmacopee.motifCorrespondance!,
                          style: (isDark
                                  ? AppTextStyles.captionDark
                                  : AppTextStyles.caption)
                              .copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.primaryDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.space8),
              ],

              // Produits correspondants disponibles dans cette pharmacopée
              if (pharmacopee.produitsDisponibles.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: pharmacopee.produitsDisponibles.take(3).map((prod) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceVariant
                            : const Color(0xFFF1F8E9),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : const Color(0xFFC8E6C9),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.medication_liquid_rounded,
                            size: 12,
                            color: Color(0xFF2E7D32),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            prod,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : const Color(0xFF1B5E20),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppDimensions.space8),
              ],

              // Étoile note moyenne & Nombre de produits disponibles
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: AppColors.accent,
                    size: 20,
                  ),
                  const SizedBox(width: AppDimensions.space4),
                  Text(
                    pharmacopee.noteMoyenne.toStringAsFixed(1),
                    style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                        .copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space4),
                  Text(
                    '(${pharmacopee.nombreAvis} avis)',
                    style: isDark
                        ? AppTextStyles.captionDark
                        : AppTextStyles.caption,
                  ),
                  const Spacer(),
                  Icon(
                    Icons.inventory_2_outlined,
                    color: isDark ? AppColors.darkPrimary : AppColors.primary,
                    size: 17,
                  ),
                  const SizedBox(width: AppDimensions.space4),
                  Text(
                    '${pharmacopee.nombreProduits} produits disponibles',
                    style: (isDark
                            ? AppTextStyles.captionDark
                            : AppTextStyles.caption)
                        .copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space12),

              // Badges : Livraison & Pickup conformes aux standards
              Row(
                children: [
                  if (pharmacopee.proposeLivraison)
                    _buildPillBadge(
                      icon: Icons.local_shipping_outlined,
                      label: 'Livraison',
                      bgColor: isDark
                          ? AppColors.darkPrimaryContainer
                          : AppColors.primaryLight,
                      textColor: isDark
                          ? AppColors.darkPrimary
                          : AppColors.primary,
                    ),
                  if (pharmacopee.proposeLivraison && pharmacopee.proposePickup)
                    const SizedBox(width: AppDimensions.space8),
                  if (pharmacopee.proposePickup)
                    _buildPillBadge(
                      icon: Icons.shopping_bag_outlined,
                      label: 'Pickup',
                      bgColor: isDark
                          ? AppColors.darkSurfaceVariant
                          : AppColors.surfaceVariant,
                      textColor: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                ],
              ),
              const SizedBox(height: AppDimensions.space16),

              // Bouton d'action principal réutilisable PrimaryButton
              PrimaryButton(
                label: 'Voir la pharmacopée',
                icon: Icons.remove_red_eye_outlined,
                onPressed: onViewDetail,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPillBadge({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: AppDimensions.paddingBadge,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusBadge),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: AppDimensions.space4),
          Text(
            label,
            style: AppTextStyles.badge.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
