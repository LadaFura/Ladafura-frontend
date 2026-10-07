import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Carte d'en-tête affichant l'officine/pharmacopée préparatrice de la commande.
class CommandePharmacopeeHeader extends StatelessWidget {
  final String nomOfficine;

  const CommandePharmacopeeHeader({
    super.key,
    required this.nomOfficine,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkAccent : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.space12),
      decoration: BoxDecoration(
        color: primaryColor.withAlpha(15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: primaryColor.withAlpha(40)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: primaryColor,
            radius: 18,
            child: const Icon(
              Icons.storefront_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fournisseur de la commande',
                  style: (isDark
                          ? AppTextStyles.captionDark
                          : AppTextStyles.caption)
                      .copyWith(fontSize: 11),
                ),
                Text(
                  nomOfficine,
                  style: (isDark ? AppTextStyles.h4Dark : AppTextStyles.h4)
                      .copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
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

