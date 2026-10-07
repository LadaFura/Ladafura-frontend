import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../models/commande_model.dart';

/// Liste des articles d'une commande avec visuel, quantité, conditionnement et sous-total.
class CommandeDetailLignesList extends StatelessWidget {
  final List<CommandeLigneModel> lignes;

  const CommandeDetailLignesList({
    super.key,
    required this.lignes,
  });

  Widget _buildProductIcon(Color primaryColor) {
    return Container(
      color: primaryColor.withAlpha(20),
      child: Center(
        child: Icon(
          Icons.medication_liquid_rounded,
          color: primaryColor,
          size: 24,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkAccent : AppColors.primary;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: lignes.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final ligne = lignes[index];
          return Padding(
            padding: const EdgeInsets.all(AppDimensions.space12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: ligne.photoUrl != null &&
                            ligne.photoUrl!.startsWith('http')
                        ? Image.network(
                            ligne.photoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildProductIcon(primaryColor),
                          )
                        : _buildProductIcon(primaryColor),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ligne.nomProduit,
                        style: (isDark
                                ? AppTextStyles.bodyDark
                                : AppTextStyles.body)
                            .copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (ligne.forme != null)
                        Text(
                          ligne.forme!,
                          style: (isDark
                                  ? AppTextStyles.captionDark
                                  : AppTextStyles.caption)
                              .copyWith(fontSize: 11),
                        ),
                      Text(
                        '${ligne.quantite} x ${ligne.prixUnitaireFormate}',
                        style: (isDark
                                ? AppTextStyles.captionDark
                                : AppTextStyles.caption)
                            .copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text(
                  ligne.sousTotalFormate,
                  style: (isDark ? AppTextStyles.h4Dark : AppTextStyles.h4)
                      .copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

