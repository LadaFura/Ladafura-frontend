import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../pharmacopees/models/pharmacopee_produit_item_model.dart';
import '../../../pharmacopees/presentation/widgets/produit_detail_modal.dart';
import '../../models/produit_model.dart';
import '../../providers/plante_provider.dart';

/// Section des produits de pharmacopée (remèdes traditionnels / Fura) formulés avec cette plante.
/// Affiche la liste des produits certifiés et permet d'ouvrir leur fiche d'achat avec officines disponibles.
class PlanteProduitsAssociesWidget extends ConsumerWidget {
  final int planteId;
  final String nomPlante;

  const PlanteProduitsAssociesWidget({
    super.key,
    required this.planteId,
    required this.nomPlante,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final produitsAsync = ref.watch(produitsByPlanteProvider(planteId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête de section
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.space8),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.darkAccent : AppColors.primary)
                    .withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.medication_rounded,
                color: isDark ? AppColors.darkAccent : AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppDimensions.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Produits & Formulations Associés',
                    style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3)
                        .copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Remèdes traditionnels préparés contenant cette plante',
                    style: (isDark
                            ? AppTextStyles.captionDark
                            : AppTextStyles.caption)
                        .copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: AppDimensions.space12),

        produitsAsync.when(
          loading: () => Container(
            height: 120,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(strokeWidth: 2.5),
          ),
          error: (err, _) => Container(
            padding: const EdgeInsets.all(AppDimensions.space16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.textMuted, size: 20),
                const SizedBox(width: AppDimensions.space8),
                Expanded(
                  child: Text(
                    'Informations sur les produits momentanément indisponibles.',
                    style: isDark
                        ? AppTextStyles.captionDark
                        : AppTextStyles.caption,
                  ),
                ),
              ],
            ),
          ),
          data: (produits) {
            if (produits.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(AppDimensions.space16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusCard),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined,
                        color: AppColors.textMuted, size: 20),
                    const SizedBox(width: AppDimensions.space8),
                    Expanded(
                      child: Text(
                        'Aucun produit commercialisé actuellement répertorié pour cette plante.',
                        style: isDark
                            ? AppTextStyles.captionDark
                            : AppTextStyles.caption,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: produits.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppDimensions.space12),
              itemBuilder: (context, index) {
                final prod = produits[index];
                return _buildProduitCard(context, prod, isDark);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildProduitCard(
    BuildContext context,
    ProduitModel prod,
    bool isDark,
  ) {
    final photoUrl = ImageUtils.resolveImageUrl(prod.photoUrl);

    return InkWell(
      onTap: () {
        // Convertir le ProduitModel en PharmacopeeProduitItemModel pour ouvrir la modale d'achat
        final itemModel = PharmacopeeProduitItemModel(
          disponibiliteId: prod.id,
          produitId: prod.id,
          nom: prod.nom,
          description: prod.description,
          forme: prod.forme,
          categorieId: prod.categorieId,
          categorieNom: prod.categorieNom,
          prix: prod.prixIndicatif,
          photoUrl: prod.photoUrl,
          quantiteStock: 10,
          disponible: prod.disponibleEnPharmacie,
        );

        ProduitDetailModal.show(context, produit: itemModel);
      },
      borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.space12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : Colors.grey.shade300)
                  .withAlpha(20),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image du produit
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              child: Container(
                width: 72,
                height: 72,
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.surfaceVariant,
                child: photoUrl != null
                    ? Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.medication_outlined,
                          color:
                              isDark ? AppColors.darkAccent : AppColors.primary,
                          size: 32,
                        ),
                      )
                    : Icon(
                        Icons.medication_outlined,
                        color:
                            isDark ? AppColors.darkAccent : AppColors.primary,
                        size: 32,
                      ),
              ),
            ),

            const SizedBox(width: AppDimensions.space12),

            // Détails du produit
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (prod.categorieNom != null) ...[
                    Text(
                      prod.categorieNom!.toUpperCase(),
                      style: (isDark
                              ? AppTextStyles.captionDark
                              : AppTextStyles.caption)
                          .copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkAccent
                            : AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    prod.nom,
                    style: (isDark ? AppTextStyles.h4Dark : AppTextStyles.h4)
                        .copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (prod.forme != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      prod.forme!,
                      style: (isDark
                              ? AppTextStyles.captionDark
                              : AppTextStyles.caption)
                          .copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        prod.prixFormate,
                        style: (isDark
                                ? AppTextStyles.h4Dark
                                : AppTextStyles.h4)
                            .copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.space8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: (isDark
                                  ? AppColors.darkAccent
                                  : AppColors.primary)
                              .withAlpha(25),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusBadge),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Consulter',
                              style: (isDark
                                      ? AppTextStyles.captionDark
                                      : AppTextStyles.caption)
                                  .copyWith(
                                color: isDark
                                    ? AppColors.darkAccent
                                    : AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 10,
                              color: isDark
                                  ? AppColors.darkAccent
                                  : AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
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
