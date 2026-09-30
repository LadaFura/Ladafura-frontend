import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

/// Bannière d'avertissement légal obligatoire conforme à l'exigence ENF11.
///
/// Rappelle que les informations botaniques et remèdes traditionnels de LADAFURA
/// sont purement informatifs et ne remplacent en aucun cas un avis médical officiel.
class MedicalDisclaimerBanner extends StatelessWidget {
  final bool compact;

  const MedicalDisclaimerBanner({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark
        ? AppColors.darkPrimaryContainer.withValues(alpha: 0.5)
        : AppColors.badgeInstitutionnelBg;
    final borderColor = isDark
        ? AppColors.darkAccent.withValues(alpha: 0.3)
        : AppColors.badgeInstitutionnelDot.withValues(alpha: 0.3);
    final iconColor = isDark ? AppColors.darkAccent : AppColors.accent;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.badgeInstitutionnelText;

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space12,
          vertical: AppDimensions.space8,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          border: Border.all(color: borderColor, width: 0.8),
        ),
        child: Row(
          children: [
            Icon(Icons.health_and_safety_outlined, size: 16, color: iconColor),
            const SizedBox(width: AppDimensions.space8),
            Expanded(
              child: Text(
                'Usage informatif (INRMPT). Ne remplace pas une consultation médicale.',
                style: AppTextStyles.caption.copyWith(
                  color: textColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppDimensions.space12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_outlined,
            size: 22,
            color: iconColor,
          ),
          const SizedBox(width: AppDimensions.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Avertissement Médical Officiel (INRMPT)',
                  style: AppTextStyles.label.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Les savoirs traditionnels et plantes répertoriés sont issus du patrimoine de la pharmacopée malienne. '
                  'Ces informations ne constituent pas un diagnostic médical ni une ordonnance. '
                  'Consultez toujours un médecin ou un agent de santé qualifié.',
                  style: AppTextStyles.caption.copyWith(
                    color: textColor,
                    fontSize: 11.5,
                    height: 1.4,
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
