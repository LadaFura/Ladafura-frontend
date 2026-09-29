import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

/// Bannière légale obligatoire selon la règle ENF11 du Cahier des Charges
/// Rappelle que LADAFURA ne remplace pas les professionnels de santé et ne fait pas de diagnostic médical.
/// Entièrement compatible Thème Clair et Thème Sombre.
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
        ? AppColors.darkPrimaryContainer
        : AppColors.primaryLight.withValues(alpha: 0.6);

    final borderColor = isDark
        ? AppColors.darkPrimary.withValues(alpha: 0.3)
        : AppColors.primary.withValues(alpha: 0.3);

    final accentColor = isDark ? AppColors.darkPrimary : AppColors.primaryDark;

    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return Container(
      padding: EdgeInsets.all(
          compact ? AppDimensions.space12 : AppDimensions.space16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(
          color: borderColor,
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: accentColor,
            size: 20,
          ),
          const SizedBox(width: AppDimensions.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Avertissement Médical',
                  style:
                      (isDark ? AppTextStyles.labelDark : AppTextStyles.label)
                          .copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.space4),
                Text(
                  'LADAFURA a un rôle exclusivement informatif. La plateforme ne remplace pas les professionnels de santé et ne pose aucun diagnostic médical.',
                  style: (isDark
                          ? AppTextStyles.captionDark
                          : AppTextStyles.caption)
                      .copyWith(
                    color: textColor,
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
