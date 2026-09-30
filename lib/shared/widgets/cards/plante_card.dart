import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../models/plante_sommaire_model.dart';
import '../media/app_cached_image.dart';

/// Carte de présentation d'une plante médicinale (réutilisée dans Population et Agent).
class PlanteCard extends StatelessWidget {
  final PlanteSommaireModel plante;
  final VoidCallback? onTap;

  const PlanteCard({
    super.key,
    required this.plante,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;

    return Card(
      color: cardBg,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        side: BorderSide(color: borderColor, width: 1.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo de la plante ou placeholder botanique
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: plante.hasPhoto
                      ? AppCachedImage(
                          imageUrl: plante.photoUrl!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: isDark
                              ? AppColors.darkPrimaryContainer
                              : AppColors.primaryLight,
                          child: Icon(
                            Icons.eco_outlined,
                            size: 32,
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.primary,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: AppDimensions.space12),

              // Informations textuelles
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom local ou vernaculaire principal
                    Text(
                      plante.nomVernaculairePrincipal,
                      style: (isDark ? AppTextStyles.h4Dark : AppTextStyles.h4)
                          .copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    // Nom scientifique botanique (en italique)
                    Text(
                      plante.nomScientifique,
                      style: (isDark
                              ? AppTextStyles.bodySecondaryDark
                              : AppTextStyles.bodySecondary)
                          .copyWith(
                        fontStyle: FontStyle.italic,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.space8),

                    // Badges indicateurs : Savoirs ancestraux & Études scientifiques
                    Wrap(
                      spacing: AppDimensions.space8,
                      runSpacing: 4,
                      children: [
                        if (plante.hasSavoirsTraditionnels)
                          _InfoTag(
                            icon: Icons.history_edu,
                            label: '${plante.nombreConnaissances} savoirs',
                            color: AppColors.accent,
                          ),
                        if (plante.hasEtudesScientifiques)
                          _InfoTag(
                            icon: Icons.science_outlined,
                            label: '${plante.nombreEtudesScientifiques} études',
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.primary,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Flèche d'ouverture
              Icon(
                Icons.chevron_right,
                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoTag({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
