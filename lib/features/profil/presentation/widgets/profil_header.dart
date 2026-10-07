import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../models/profil_model.dart';

/// En-tête moderne du profil avec icône utilisateur générique, identité et statut.
class ProfilHeader extends StatelessWidget {
  final ProfilModel? profil;

  const ProfilHeader({
    super.key,
    required this.profil,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkAccent : AppColors.primary;

    final nomComplet = profil?.nomComplet.isNotEmpty == true
        ? profil!.nomComplet
        : 'Citoyen LADAFURA';
    final email = profil?.email ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space20,
        vertical: AppDimensions.space24,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          // Icône utilisateur générique (pas de photo de profil)
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withAlpha(25),
              border: Border.all(
                color: primaryColor.withAlpha(80),
                width: 2,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.person_rounded,
                size: 48,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.space12),

          // Prénom et Nom
          Text(
            nomComplet,
            style: (isDark ? AppTextStyles.h2Dark : AppTextStyles.h2).copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // Email
          if (email.isNotEmpty)
            Text(
              email,
              style: (isDark
                      ? AppTextStyles.captionDark
                      : AppTextStyles.caption)
                  .copyWith(fontSize: 13),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 10),

          // Badges Rôle et Statut
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: primaryColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_outlined, size: 13, color: primaryColor),
                    const SizedBox(width: 4),
                    Text(
                      'Population',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        size: 13, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      profil?.statut == 'ACTIF' ? 'Actif' : (profil?.statut ?? 'Actif'),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

