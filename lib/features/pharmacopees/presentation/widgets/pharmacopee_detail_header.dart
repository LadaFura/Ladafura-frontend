import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/services_providers.dart';
import '../../../../core/utils/image_utils.dart';
import '../../models/pharmacopee_detail_model.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../shared/widgets/navigation/navigation_provider.dart';

/// En-tête moderne et immersif pour la fiche d'une pharmacopée agréée.
/// - Grande image avec overlay en dégradé
/// - Boutons retour et favori flottants
/// - Nom, note, avis et description
/// - Contact téléphonique rapide
/// - Adresse réelle et distance GPS dynamique avec action "Voir sur la carte"
class PharmacopeeDetailHeader extends ConsumerWidget {
  final PharmacopeeDetailModel pharmacopee;
  final VoidCallback? onVoirAvis;

  const PharmacopeeDetailHeader({
    super.key,
    required this.pharmacopee,
    this.onVoirAvis,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userPositionAsync = ref.watch(userLocationProvider);

    // Calcul de la distance réelle si disponible
    final distanceText = userPositionAsync.maybeWhen(
      data: (coords) => pharmacopee.distanceFormatee(coords),
      orElse: () => null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Grande photo de couverture avec dégradé et boutons d'action
        Stack(
          children: [
            // Image avec ratio élégant
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF142B20) : const Color(0xFFE8F5E9),
              ),
              child: _buildCoverImage(isDark),
            ),

            // Dégradé pour lisibilité
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withAlpha(120),
                      Colors.transparent,
                      Colors.black.withAlpha(80),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),

            // Bouton retour rond sur l'image
            Positioned(
              top: MediaQuery.paddingOf(context).top + 8,
              left: AppDimensions.space16,
              child: Material(
                color: Colors.black.withAlpha(100),
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 20),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      Navigator.of(context).maybePop();
                    }
                  },
                ),
              ),
            ),

            // Badge officiel "Pharmacopée agréée" en haut à droite
            Positioned(
              top: MediaQuery.paddingOf(context).top + 14,
              right: AppDimensions.space16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(40),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_rounded, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Agréée LADAFURA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // 2. Fiche d'informations principales sous l'image avec coins arrondis élégants
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space16,
            vertical: AppDimensions.space12,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nom de la pharmacopée (sans bouton d'appel en doublon ici)
              Text(
                pharmacopee.nom,
                style: (isDark ? AppTextStyles.h2Dark : AppTextStyles.h2)
                    .copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),

              // Étoiles de note, nombre d'avis et remèdes disponibles (cliquable pour basculer vers les avis)
              const SizedBox(height: 6),
              InkWell(
                onTap: onVoirAvis,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 18, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text(
                        pharmacopee.noteMoyenne > 0
                            ? pharmacopee.noteMoyenne.toStringAsFixed(1)
                            : '5.0',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${pharmacopee.nombreAvis} avis)',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                          decoration: onVoirAvis != null
                              ? TextDecoration.underline
                              : null,
                        ),
                      ),
                      if (pharmacopee.nombreProduits > 0) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '•',
                            style: TextStyle(
                              color: isDark ? Colors.white38 : Colors.grey.shade400,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          '${pharmacopee.nombreProduits} remèdes',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkPrimary : AppColors.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Description
              if (pharmacopee.description != null &&
                  pharmacopee.description!.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.space8),
                Text(
                  pharmacopee.description!,
                  style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                      .copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],

              const SizedBox(height: AppDimensions.space12),

              // 3. Localisation & Distance & Action "Voir sur la carte"
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pharmacopee.localisation?.adresseComplete ?? 'Mali',
                          style: (isDark
                                  ? AppTextStyles.bodyDark
                                  : AppTextStyles.body)
                              .copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            if (distanceText != null) ...[
                              Text(
                                distanceText,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                              const Text(' • ',
                                  style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 12)),
                            ],
                            InkWell(
                              onTap: () {
                                final isCitizen = GoRouterState.of(context).uri.toString().startsWith('/citizen');
                                final cartePath = isCitizen ? RouteNames.citizenCartePath : RouteNames.visitorCartePath;
                                ref.read(navigationIndexProvider.notifier).setIndex(2);
                                context.go(cartePath);
                              },
                              child: const Text(
                                'Voir sur la carte',
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCoverImage(bool isDark) {
    final resolved = ImageUtils.resolveImageUrl(pharmacopee.photoUrl);
    if (resolved != null && resolved.isNotEmpty) {
      if (resolved.startsWith('assets/')) {
        return Image.asset(
          resolved,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallback(isDark),
        );
      }
      return CachedNetworkImage(
        imageUrl: resolved,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          color: isDark ? const Color(0xFF142B20) : const Color(0xFFE8F5E9),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (_, __, ___) => _buildFallback(isDark),
      );
    }
    return _buildFallback(isDark);
  }

  Widget _buildFallback(bool isDark) {
    return Image.asset(
      'assets/images/pharmacie_sample.png',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: isDark ? const Color(0xFF142B20) : const Color(0xFFE8F5E9),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_pharmacy_rounded,
                size: 54,
                color:
                    isDark ? const Color(0xFF2ECC71) : const Color(0xFF2E7D32),
              ),
              const SizedBox(height: 8),
              Text(
                'Pharmacopée Traditionnelle',
                style: TextStyle(
                  color: isDark ? Colors.white70 : AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
