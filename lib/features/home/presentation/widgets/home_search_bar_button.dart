import 'package:flutter/material.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';

/// Barre de recherche cliquable pour l'accueil menant directement à la page de recherche.
class HomeSearchBarButton extends StatelessWidget {
  final VoidCallback onTap;
  final String hintText;

  const HomeSearchBarButton({
    super.key,
    required this.onTap,
    this.hintText = 'Rechercher une plante, remède, maladie...',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      button: true,
      label: 'Rechercher dans LADAFURA',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F2),
            borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8E4),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: isDark ? Colors.white70 : const Color(0xFF0D5C3A),
                size: 22,
              ),
              const SizedBox(width: AppDimensions.space12),
              Expanded(
                child: Text(
                  hintText,
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextMuted : const Color(0xFF7A8B80),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

