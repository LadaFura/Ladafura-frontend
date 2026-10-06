import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/image_utils.dart';
import '../../models/pharmacopee_model.dart';

class PharmacopeeHeaderCard extends StatelessWidget {
  final PharmacopeeModel pharmacopee;

  const PharmacopeeHeaderCard({super.key, required this.pharmacopee});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bannière / Photo de l'officine
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard - 4),
            child: SizedBox(
              height: 160,
              width: double.infinity,
              child: _buildBannerImage(isDark),
            ),
          ),
          const SizedBox(height: AppDimensions.space16),

          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.darkAccent : AppColors.primary)
                      .withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_pharmacy_rounded,
                  color: isDark ? AppColors.darkAccent : AppColors.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: AppDimensions.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pharmacopee.nom,
                      style: isDark ? AppTextStyles.h2Dark : AppTextStyles.h2,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 16, color: AppColors.accent),
                        const SizedBox(width: 4),
                        Text(
                          '${pharmacopee.noteMoyenne.toStringAsFixed(1)} (${pharmacopee.nombreAvis} avis)',
                          style: isDark
                              ? AppTextStyles.captionDark
                              : AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space16),

          // Adresse
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 18, color: AppColors.textMuted),
              const SizedBox(width: AppDimensions.space8),
              Expanded(
                child: Text(
                  pharmacopee.adresseComplete,
                  style: isDark ? AppTextStyles.bodyDark : AppTextStyles.body,
                ),
              ),
            ],
          ),

          // Téléphone
          if (pharmacopee.telephone != null &&
              pharmacopee.telephone!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.space8),
            Row(
              children: [
                const Icon(Icons.phone_outlined,
                    size: 18, color: AppColors.textMuted),
                const SizedBox(width: AppDimensions.space8),
                Text(
                  pharmacopee.telephone!,
                  style: isDark ? AppTextStyles.bodyDark : AppTextStyles.body,
                ),
              ],
            ),
          ],

          // Description
          if (pharmacopee.description != null &&
              pharmacopee.description!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.space12),
            Text(
              pharmacopee.description!,
              style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                  .copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ],

          // Badges livraison & retrait
          const SizedBox(height: AppDimensions.space16),
          Row(
            children: [
              if (pharmacopee.proposeLivraison)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space8,
                    vertical: AppDimensions.space4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(20),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusBadge),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.delivery_dining_rounded,
                          size: 14, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text(
                        'Livraison disponible',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(width: AppDimensions.space8),
              if (pharmacopee.proposePickup)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space8,
                    vertical: AppDimensions.space4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusBadge),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.storefront_outlined,
                          size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Retrait sur place',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
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

  Widget _buildBannerImage(bool isDark) {
    final resolvedUrl = ImageUtils.resolveImageUrl(pharmacopee.photoUrl);
    if (resolvedUrl != null) {
      return Image.network(
        resolvedUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackImage(isDark),
      );
    }
    return _buildFallbackImage(isDark);
  }

  Widget _buildFallbackImage(bool isDark) {
    return Image.asset(
      'assets/images/pharmacie_sample.png',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: isDark ? const Color(0xFF1E3A2F) : const Color(0xFFE8F5E9),
        child: Center(
          child: Icon(
            Icons.local_pharmacy_rounded,
            size: 48,
            color: isDark ? const Color(0xFF2ECC71) : const Color(0xFF2E7D32),
          ),
        ),
      ),
    );
  }
}
