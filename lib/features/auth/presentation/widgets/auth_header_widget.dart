import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/media/app_logo.dart';

/// En-tête officiel des écrans d'authentification LADAFURA.
///
/// Met en valeur le logo vectoriel officiel de LADAFURA sans fond, adapté aux modes clair et sombre.
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
        // Logo emblème officiel LADAFURA sans fond (adapté clair/sombre)
        const Hero(
          tag: 'ladafura-logo',
          child: AppLogo.icon(
            size: 76,
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
              'Plateforme Nationale de la Pharmacopée Traditionnelle Malienne',
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
