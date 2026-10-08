import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../shared/widgets/feedback/medical_disclaimer_banner.dart';
import '../../models/plante_model.dart';

class PlanteHeaderCard extends StatelessWidget {
  final PopulationPlanteDetailModel plante;

  const PlanteHeaderCard({super.key, required this.plante});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Photo principale ou placeholder
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          child: Container(
            height: 220,
            width: double.infinity,
            color: isDark ? AppColors.darkSurface : AppColors.surfaceVariant,
            child: _buildHeaderImage(isDark),
          ),
        ),
        const SizedBox(height: AppDimensions.space16),

        // Nom scientifique (texte standard)
        Text(
          plante.nomScientifique,
          style: (isDark ? AppTextStyles.h1Dark : AppTextStyles.h1).copyWith(
            color: isDark ? AppColors.darkPrimary : AppColors.primary,
          ),
        ),

        // Noms vernaculaires
        if (plante.nomsVernaculaires.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.space8),
          Wrap(
            spacing: AppDimensions.space8,
            runSpacing: AppDimensions.space4,
            children: plante.nomsVernaculaires.map((v) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space8,
                  vertical: AppDimensions.space4,
                ),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.darkPrimary : AppColors.primary)
                      .withAlpha(25),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusBadge),
                  border: Border.all(
                    color: (isDark ? AppColors.darkPrimary : AppColors.primary)
                        .withAlpha(60),
                  ),
                ),
                child: Text(
                  v.langue.trim().isNotEmpty
                      ? '${v.nom} (${v.langue})'
                      : v.nom,
                  style: (isDark ? AppTextStyles.captionDark : AppTextStyles.caption)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              );
            }).toList(),
          ),
        ],

        // Description
        if (plante.description.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.space12),
          Text(
            plante.description,
            style: isDark ? AppTextStyles.bodyDark : AppTextStyles.body,
          ),
        ],

        // Avertissement médical officiel
        const SizedBox(height: AppDimensions.space16),
        const MedicalDisclaimerBanner(compact: false),
      ],
    );
  }

  Widget _buildHeaderImage(bool isDark) {
    final resolvedUrl = ImageUtils.resolveImageUrl(plante.photoUrl);
    if (resolvedUrl != null) {
      return Image.network(
        resolvedUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(isDark),
      );
    }
    return _buildPlaceholder(isDark);
  }

  Widget _buildPlaceholder(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.eco_rounded,
            size: 64,
            color: isDark ? AppColors.darkPrimary : AppColors.primary,
          ),
          const SizedBox(height: AppDimensions.space8),
          Text(
            'Flore Médicinale Malienne',
            style: (isDark ? AppTextStyles.captionDark : AppTextStyles.caption)
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
