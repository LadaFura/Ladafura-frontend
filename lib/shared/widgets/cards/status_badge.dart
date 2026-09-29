import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

/// Types de badges certifiés selon le Design System LADAFURA et la règle ENF11
enum StatusBadgeType {
  usageTraditionnel,
  etudeScientifique,
  informationInstitutionnelle,
  enCoursVerification,
}

/// Widget Badge officiel LADAFURA (Pill shape, radius 999 px, point coloré + texte Poppins 12 px)
/// Compatible nativement Thème Clair et Thème Sombre.
class StatusBadge extends StatelessWidget {
  final StatusBadgeType type;
  final String? customLabel;

  const StatusBadge({
    super.key,
    required this.type,
    this.customLabel,
  });

  /// Constructeur nommé pratique : Usage traditionnel rapporté
  const StatusBadge.traditionnel({super.key, this.customLabel})
      : type = StatusBadgeType.usageTraditionnel;

  /// Constructeur nommé pratique : Étude scientifique disponible
  const StatusBadge.scientifique({super.key, this.customLabel})
      : type = StatusBadgeType.etudeScientifique;

  /// Constructeur nommé pratique : Information institutionnelle
  const StatusBadge.institutionnel({super.key, this.customLabel})
      : type = StatusBadgeType.informationInstitutionnelle;

  /// Constructeur nommé pratique : En cours de vérification
  const StatusBadge.enVerification({super.key, this.customLabel})
      : type = StatusBadgeType.enCoursVerification;

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space12,
        vertical: AppDimensions.space4 + 2,
      ),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusBadge),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppDimensions.badgeDotSize,
            height: AppDimensions.badgeDotSize,
            decoration: BoxDecoration(
              color: config.dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppDimensions.space8),
          Flexible(
            child: Text(
              customLabel ?? config.label,
              style: AppTextStyles.badge.copyWith(color: config.textColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeConfig _getConfig(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (type) {
      case StatusBadgeType.usageTraditionnel:
        return _BadgeConfig(
          label: 'Usage traditionnel rapporté',
          backgroundColor: isDark
              ? AppColors.darkBadgeTraditionnelBg
              : AppColors.badgeTraditionnelBg,
          dotColor: isDark
              ? AppColors.darkBadgeTraditionnelDot
              : AppColors.badgeTraditionnelDot,
          textColor: isDark
              ? AppColors.darkBadgeTraditionnelText
              : AppColors.badgeTraditionnelText,
        );
      case StatusBadgeType.etudeScientifique:
        return _BadgeConfig(
          label: 'Étude scientifique disponible',
          backgroundColor: isDark
              ? AppColors.darkBadgeScientifiqueBg
              : AppColors.badgeScientifiqueBg,
          dotColor: isDark
              ? AppColors.darkBadgeScientifiqueDot
              : AppColors.badgeScientifiqueDot,
          textColor: isDark
              ? AppColors.darkBadgeScientifiqueText
              : AppColors.badgeScientifiqueText,
        );
      case StatusBadgeType.informationInstitutionnelle:
        return _BadgeConfig(
          label: 'Information institutionnelle',
          backgroundColor: isDark
              ? AppColors.darkBadgeInstitutionnelBg
              : AppColors.badgeInstitutionnelBg,
          dotColor: isDark
              ? AppColors.darkBadgeInstitutionnelDot
              : AppColors.badgeInstitutionnelDot,
          textColor: isDark
              ? AppColors.darkBadgeInstitutionnelText
              : AppColors.badgeInstitutionnelText,
        );
      case StatusBadgeType.enCoursVerification:
        return _BadgeConfig(
          label: 'En cours de vérification',
          backgroundColor: isDark
              ? AppColors.darkBadgeVerificationBg
              : AppColors.badgeVerificationBg,
          dotColor: isDark
              ? AppColors.darkBadgeVerificationDot
              : AppColors.badgeVerificationDot,
          textColor: isDark
              ? AppColors.darkBadgeVerificationText
              : AppColors.badgeVerificationText,
        );
    }
  }
}

class _BadgeConfig {
  final String label;
  final Color backgroundColor;
  final Color dotColor;
  final Color textColor;

  _BadgeConfig({
    required this.label,
    required this.backgroundColor,
    required this.dotColor,
    required this.textColor,
  });
}
