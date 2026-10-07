import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';


/// Modal ou écran de sélection de l'officine de pharmacopée pour un produit.
class PharmacopeeSelectionModal extends StatelessWidget {
  final String nomProduit;
  final List<dynamic> offres;
  final Function(int pharmacopeeId, String nomPharmacopee) onPharmacopeeSelected;

  const PharmacopeeSelectionModal({
    super.key,
    required this.nomProduit,
    required this.offres,
    required this.onPharmacopeeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkAccent : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.space20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Icon(Icons.storefront_rounded, color: primaryColor, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Choisir une officine',
                    style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3)
                        .copyWith(fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Sélectionnez la pharmacopée auprès de laquelle commander "$nomProduit" :',
              style: (isDark ? AppTextStyles.captionDark : AppTextStyles.caption)
                  .copyWith(fontSize: 13),
            ),
            const SizedBox(height: 16),
            if (offres.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'Aucune pharmacopée disponible actuellement pour ce produit.',
                    style: isDark ? AppTextStyles.bodyDark : AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: offres.length,
                  separatorBuilder: (_, __) => const Divider(height: 12),
                  itemBuilder: (context, index) {
                    final offre = offres[index];
                    final pharmacopeeId = (offre['pharmacopeeId'] as num?)?.toInt() ?? 0;
                    final nomPharmacopee =
                        offre['nomPharmacopee']?.toString() ?? 'Officine agréée';
                    final prix = (offre['prix'] as num?)?.toDouble() ?? 0.0;
                    final telephone = offre['telephone']?.toString();
                    final commune = offre['commune']?.toString();
                    final stock = (offre['quantiteStock'] as num?)?.toInt() ?? 0;

                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.of(context).pop();
                        onPharmacopeeSelected(pharmacopeeId, nomPharmacopee);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 10),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: primaryColor.withAlpha(20),
                              radius: 20,
                              child: Icon(Icons.local_pharmacy_rounded,
                                  color: primaryColor, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nomPharmacopee,
                                    style: (isDark
                                            ? AppTextStyles.h4Dark
                                            : AppTextStyles.h4)
                                        .copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (commune != null)
                                    Text(
                                      commune,
                                      style: (isDark
                                              ? AppTextStyles.captionDark
                                              : AppTextStyles.caption)
                                          .copyWith(fontSize: 12),
                                    ),
                                  if (telephone != null)
                                    Text(
                                      telephone,
                                      style: (isDark
                                              ? AppTextStyles.captionDark
                                              : AppTextStyles.caption)
                                          .copyWith(
                                        fontSize: 11,
                                        color: isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${prix.round()} FCFA',
                                  style: (isDark
                                          ? AppTextStyles.h4Dark
                                          : AppTextStyles.h4)
                                      .copyWith(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '$stock en stock',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: stock > 0
                                        ? Colors.green
                                        : Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
