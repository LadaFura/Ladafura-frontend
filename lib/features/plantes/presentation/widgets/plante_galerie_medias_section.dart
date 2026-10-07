import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/image_utils.dart';
import '../../models/plante_model.dart';

/// Galerie multimédia pour les photos de terrain collectées par les agents LADAFURA.
class PlanteGalerieMediasSection extends StatelessWidget {
  final List<PopulationPlanteMediaModel> medias;

  const PlanteGalerieMediasSection({
    super.key,
    required this.medias,
  });

  @override
  Widget build(BuildContext context) {
    // Filtrer les médias de type image pour la galerie visuelle
    final photos = medias
        .where((m) =>
            m.typeMedia != 'AUDIO_TERRAIN' &&
            m.typeMedia != 'AUDIO' &&
            !m.url.toLowerCase().endsWith('.mp3') &&
            !m.url.toLowerCase().endsWith('.wav'))
        .toList();

    if (photos.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.space8),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.darkAccent : AppColors.primary)
                    .withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.photo_library_rounded,
                color: isDark ? AppColors.darkAccent : AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppDimensions.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Galerie & Photos de Terrain',
                    style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3)
                        .copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Clichés photographiques pris in situ lors des collectes botaniques',
                    style: (isDark
                            ? AppTextStyles.captionDark
                            : AppTextStyles.caption)
                        .copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: AppDimensions.space12),

        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: photos.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: AppDimensions.space12),
            itemBuilder: (context, index) {
              final photo = photos[index];
              final resolvedUrl = ImageUtils.resolveImageUrl(photo.url);

              return ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                child: Container(
                  width: 170,
                  color: isDark
                      ? AppColors.darkSurfaceVariant
                      : AppColors.surfaceVariant,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (resolvedUrl != null)
                        Image.network(
                          resolvedUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.image_not_supported_rounded,
                                color: AppColors.textMuted),
                          ),
                        )
                      else
                        const Center(
                          child: Icon(Icons.eco_rounded,
                              color: AppColors.textMuted),
                        ),
                      if (photo.description != null &&
                          photo.description!.isNotEmpty)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withAlpha(180),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: Text(
                              photo.description!,
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white,
                                fontSize: 10.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

