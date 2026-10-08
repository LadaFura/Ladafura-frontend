import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../models/pharmacopee_avis_item_model.dart';
import '../../models/pharmacopee_eligibilite_avis_model.dart';

/// Section des avis clients et note pour la pharmacopée :
/// - Note moyenne globale avec répartition en étoiles
/// - Liste des avis vérifiés avec date et nom de l'auteur
/// - Bouton d'action "Donner mon avis" ou "Modifier mon avis"
class PharmacopeeAvisSection extends StatelessWidget {
  final List<PharmacopeeAvisItemModel> avis;
  final double noteMoyenne;
  final int nombreAvis;
  final PharmacopeeEligibiliteAvisModel? eligibilite;
  final VoidCallback onDonnerAvis;

  const PharmacopeeAvisSection({
    super.key,
    required this.avis,
    required this.noteMoyenne,
    required this.nombreAvis,
    this.eligibilite,
    required this.onDonnerAvis,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final noteAffichee = noteMoyenne > 0 ? noteMoyenne.toStringAsFixed(1) : '5.0';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre de la section (Design épuré sans bouton redondant)
          Text(
            'Avis & Expériences ($nombreAvis)',
            style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3).copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.space12),

          // Carte de synthèse de note
          Container(
            padding: const EdgeInsets.all(AppDimensions.space16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                // Note géante
                Column(
                  children: [
                    Text(
                      noteAffichee,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: List.generate(
                        5,
                        (i) => const Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$nombreAvis avis',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                const VerticalDivider(width: 1),
                const SizedBox(width: 16),
                // Explication de la modération LADAFURA
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.verified_user_rounded, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Avis 100% vérifiés',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Seuls les clients ayant commandé auprès de cette pharmacopée peuvent partager leur retour d\'expérience.',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.space16),

          // Liste des avis réels
          if (avis.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.space20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 32,
                    color: isDark ? Colors.white30 : Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aucun avis publié pour le moment.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Soyez le premier à donner votre avis après votre commande !',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
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
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Nom de l'auteur
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkPrimaryContainer : AppColors.primaryLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person_rounded, size: 14, color: AppColors.primary),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.auteurNomComplet,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : AppColors.textPrimary,
                                  ),
                                ),
                                if (item.dateAvis != null)
                                  Text(
                                    '${item.dateAvis!.day.toString().padLeft(2, '0')}/${item.dateAvis!.month.toString().padLeft(2, '0')}/${item.dateAvis!.year}',
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                              ],
                            ),
                          ),
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
                        ],
                      ),
                      if (item.commentaire != null && item.commentaire!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          item.commentaire!,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textPrimary,
                            height: 1.35,
                          ),
                        ),
                      ],
                      // Réponse de l'officine/pharmacopée si disponible
                      if (item.reponseOfficine != null &&
                          item.reponseOfficine!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withAlpha(8)
                                : const Color(0xFFF1F8F4),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.primary.withAlpha(40)
                                  : const Color(0xFFC8E6C9),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.reply_rounded,
                                  size: 16, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Réponse de la pharmacopée :',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.reponseOfficine!,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
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
