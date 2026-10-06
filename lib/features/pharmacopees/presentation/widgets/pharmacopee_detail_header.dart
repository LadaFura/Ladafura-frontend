import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/services_providers.dart';
import '../../../../core/utils/image_utils.dart';
import '../../models/pharmacopee_detail_model.dart';

/// En-tête moderne et immersif pour la fiche d'une pharmacopée agréée.
/// - Grande image avec overlay en dégradé
/// - Boutons retour et favori flottants
/// - Nom, note, avis et description
/// - Contact téléphonique rapide
/// - Adresse réelle et distance GPS dynamique avec action "Voir sur la carte"
class PharmacopeeDetailHeader extends ConsumerWidget {
  final PharmacopeeDetailModel pharmacopee;

  const PharmacopeeDetailHeader({
    super.key,
    required this.pharmacopee,
  });

  void _showContactInfo(BuildContext context, String phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Numéro de contact : $phone'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 3),
      ),
    );
  }

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
              height: 220,
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
                      Colors.black.withAlpha(140),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),

            // Bouton retour rond
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

            // Note et avis au bas de la couverture
            Positioned(
              bottom: 12,
              left: AppDimensions.space16,
              right: AppDimensions.space16,
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(140),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 16, color: AppColors.accent),
                        const SizedBox(width: 4),
                        Text(
                          pharmacopee.noteMoyenne > 0
                              ? pharmacopee.noteMoyenne.toStringAsFixed(1)
                              : '5.0',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${pharmacopee.nombreAvis} avis)',
                          style: TextStyle(
                            color: Colors.white.withAlpha(200),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (pharmacopee.nombreProduits > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.darkPrimary.withAlpha(200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.medication_rounded,
                              size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '${pharmacopee.nombreProduits} remèdes',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),

        // 2. Fiche d'informations principales sous l'image avec coins arrondis élégants
        Container(
          padding: const EdgeInsets.only(
            left: AppDimensions.space16,
            right: AppDimensions.space16,
            top: AppDimensions.space16,
            bottom: AppDimensions.space8,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
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
              // Nom & Bouton d'appel rapide
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      pharmacopee.nom,
                      style: (isDark ? AppTextStyles.h2Dark : AppTextStyles.h2)
                          .copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  if (pharmacopee.telephone != null &&
                      pharmacopee.telephone!.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      onPressed: () =>
                          _showContactInfo(context, pharmacopee.telephone!),
                      icon: const Icon(Icons.phone_in_talk_rounded, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                        foregroundColor: AppColors.primary,
                      ),
                      tooltip: 'Appeler la pharmacopée',
                    ),
                  ],
                ],
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
                                // Naviguer vers la carte avec focus sur cette pharmacopée
                                context.push('/map?focusId=${pharmacopee.id}');
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
    if (resolved != null) {
      return Image.network(
        resolved,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallback(isDark),
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
