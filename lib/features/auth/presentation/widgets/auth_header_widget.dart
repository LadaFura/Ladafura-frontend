import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_assets.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_text_styles.dart';

/// En-tête officiel des écrans d'authentification LADAFURA.
///
/// Met en valeur le logo vectoriel institutionnel et la tutelle de l'INRMPT.
class AuthHeaderWidget extends StatelessWidget {
  final String title;
  final String? subtitle;

  const AuthHeaderWidget({
    super.key,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Logo emblème officiel LADAFURA
        Hero(
          tag: 'ladafura-logo',
          child: Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(AppDimensions.space12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkPrimaryContainer
                  : AppColors.badgeTraditionnelBg,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              AppAssets.logoEmbleme,
              semanticsLabel: 'Logo LADAFURA',
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.space16),

        // Titre de l'écran (ex: "Bienvenue sur LADAFURA")
        Text(
          title,
          style: isDark ? AppTextStyles.h2Dark : AppTextStyles.h2,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.space8),

        // Mention institutionnelle ou sous-titre
        Text(
          subtitle ??
              'Plateforme Nationale de la Pharmacopée Traditionnelle • INRMPT Mali',
          style: (isDark
                  ? AppTextStyles.bodySecondaryDark
                  : AppTextStyles.bodySecondary)
              .copyWith(
            color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
