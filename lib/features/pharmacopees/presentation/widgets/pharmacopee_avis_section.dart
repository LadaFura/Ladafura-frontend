import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../models/pharmacopee_avis_item_model.dart';

/// Section présentant les avis vérifiés des usagers pour la pharmacopée.
class PharmacopeeAvisSection extends StatelessWidget {
  final List<PharmacopeeAvisItemModel> avis;

  const PharmacopeeAvisSection({
    super.key,
    required this.avis,
  });

  @override
  Widget build(BuildContext context) {
    if (avis.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.rate_review_rounded,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Avis des usagers (${avis.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: avis.length > 5 ? 5 : avis.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = avis[index];
              return Container(
                padding: const EdgeInsets.all(AppDimensions.space12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Étoiles de note
                        Row(
                          children: List.generate(
                            5,
                            (starIndex) => Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: starIndex < item.note
                                  ? AppColors.accent
                                  : Colors.grey.shade300,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (item.dateAvis != null)
                          Text(
                            '${item.dateAvis!.day}/${item.dateAvis!.month}/${item.dateAvis!.year}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                      ],
                    ),
                    if (item.commentaire != null &&
                        item.commentaire!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        item.commentaire!,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                    // Réponse de l'officine/pharmacopée si disponible
                    if (item.reponseOfficine != null &&
                        item.reponseOfficine!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withAlpha(8)
                              : const Color(0xFFF1F8F4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.reply_rounded,
                                size: 14, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Réponse : ${item.reponseOfficine}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

