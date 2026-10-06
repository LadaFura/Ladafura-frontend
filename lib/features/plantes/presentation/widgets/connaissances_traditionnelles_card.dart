import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../models/plante_model.dart';

class ConnaissancesTraditionnellesCard extends StatelessWidget {
  final List<PopulationConnaissanceTraditionnelleModel> connaissances;

  const ConnaissancesTraditionnellesCard({
    super.key,
    required this.connaissances,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (connaissances.isEmpty) {
      return Container(
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
                'Aucune connaissance traditionnelle renseignée pour le moment.',
                style: isDark ? AppTextStyles.captionDark : AppTextStyles.caption,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.history_edu_rounded,
                color: AppColors.accent, size: 22),
            const SizedBox(width: AppDimensions.space8),
            Text(
              'Savoirs Traditionnels & Usages (${connaissances.length})',
              style: isDark ? AppTextStyles.h3Dark : AppTextStyles.h3,
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.space12),
        ...connaissances.map((c) => _buildItemCard(context, c, isDark)),
      ],
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    PopulationConnaissanceTraditionnelleModel item,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.space12),
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_outline_rounded,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: AppDimensions.space8),
              Expanded(
                child: Text(
                  item.usageRapporte,
                  style: (isDark ? AppTextStyles.h4Dark : AppTextStyles.h4)
                      .copyWith(color: isDark ? AppColors.darkAccent : AppColors.primary),
                ),
              ),
            ],
          ),

          if (item.partieUtilisee != null && item.partieUtilisee!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.space8),
            _buildDetailRow(
              'Partie utilisée',
              item.partieUtilisee!,
              Icons.spa_outlined,
              isDark,
            ),
          ],

          if (item.modePreparation != null && item.modePreparation!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.space8),
            _buildDetailRow(
              'Mode de préparation',
              item.modePreparation!,
              Icons.soup_kitchen_outlined,
              isDark,
            ),
          ],

          if (item.posologie != null && item.posologie!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.space8),
            _buildDetailRow(
              'Posologie',
              item.posologie!,
              Icons.medical_services_outlined,
              isDark,
            ),
          ],

          if (item.precautions != null && item.precautions!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.space8),
            Container(
              padding: const EdgeInsets.all(AppDimensions.space8),
              decoration: BoxDecoration(
                color: AppColors.warning.withAlpha(25),
                borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                border: Border.all(color: AppColors.warning.withAlpha(80)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.warning, size: 16),
                  const SizedBox(width: AppDimensions.space8),
                  Expanded(
                    child: Text(
                      'Précautions : ${item.precautions}',
                      style: (isDark ? AppTextStyles.captionDark : AppTextStyles.caption)
                          .copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (item.informateurSource != null &&
              item.informateurSource!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.space8),
            Text(
              'Source : ${item.informateurSource}',
              style: (isDark ? AppTextStyles.captionDark : AppTextStyles.caption)
                  .copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: isDark ? AppColors.darkAccent : AppColors.primary),
        const SizedBox(width: AppDimensions.space8),
        Text(
          '$label : ',
          style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body).copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body).copyWith(
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
