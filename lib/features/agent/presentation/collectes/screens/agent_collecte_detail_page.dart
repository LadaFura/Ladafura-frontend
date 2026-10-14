import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ladafura_frontend_flutter/core/constants/api_endpoints.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_text_styles.dart';
import 'package:ladafura_frontend_flutter/core/routing/route_names.dart';
import 'package:ladafura_frontend_flutter/features/agent/models/agent_collecte_detail_model.dart';
import 'package:ladafura_frontend_flutter/features/agent/models/agent_recapitulatif_model.dart';
import 'package:ladafura_frontend_flutter/features/agent/providers/agent_providers.dart';
import 'package:ladafura_frontend_flutter/features/plantes/presentation/widgets/plante_audio_player_card.dart';

/// Écran de consultation détaillée d'une fiche de collecte de terrain.
class AgentCollecteDetailPage extends ConsumerWidget {
  final int collecteId;

  const AgentCollecteDetailPage({super.key, required this.collecteId});

  _StatusStyle _getStatusStyle(String statut) {
    switch (statut.toUpperCase()) {
      case 'VALIDEE':
        return const _StatusStyle(
          label: 'Validée',
          color: Color(0xFF15803D),
          bgColor: Color(0xFFDCFCE7),
          icon: Icons.verified_rounded,
        );
      case 'REJETEE':
        return const _StatusStyle(
          label: 'À corriger',
          color: AppColors.danger,
          bgColor: Color(0xFFFEE2E2),
          icon: Icons.error_outline_rounded,
        );
      case 'SOUMISE':
      case 'EN_EXAMEN':
        return const _StatusStyle(
          label: 'En examen',
          color: Color(0xFFB45309),
          bgColor: Color(0xFFFEF3C7),
          icon: Icons.hourglass_top_rounded,
        );
      case 'BROUILLON':
      default:
        return const _StatusStyle(
          label: 'Brouillon',
          color: Color(0xFF475569),
          bgColor: Color(0xFFF1F5F9),
          icon: Icons.edit_note_rounded,
        );
    }
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '';
    try {
      final dt = DateTime.parse(rawDate);
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      return '$day/$month/${dt.year}';
    } catch (_) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final detailAsync = ref.watch(agentCollecteDetailProvider(collecteId));
    final recapAsync = ref.watch(agentCollecteRecapitulatifProvider(collecteId));
    final recap = recapAsync.valueOrNull;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Détail de la collecte',
          style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3).copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, size: 48, color: Colors.orange),
                const SizedBox(height: 12),
                Text(
                  'Impossible de charger cette fiche de collecte.',
                  textAlign: TextAlign.center,
                  style: isDark ? AppTextStyles.bodyDark : AppTextStyles.body,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(agentCollecteDetailProvider(collecteId));
                    ref.invalidate(agentCollecteRecapitulatifProvider(collecteId));
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
        data: (detail) {
          final statusStyle = _getStatusStyle(detail.statut);
          final hasPhoto = detail.photoUrl != null && detail.photoUrl!.isNotEmpty;
          final hasAudio = detail.audioUrl != null && detail.audioUrl!.isNotEmpty;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Carte En-tête Hero (Photo + Plante + Statut + Date)
                _buildHeroHeaderCard(
                  isDark: isDark,
                  detail: detail,
                  recap: recap,
                  statusStyle: statusStyle,
                  hasPhoto: hasPhoto,
                ),

                // Alerte motif de rejet si présent
                if (detail.motifRejet != null && detail.motifRejet!.trim().isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.danger.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.report_problem_rounded,
                          color: AppColors.danger,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Motif de retour du modérateur',
                                style: TextStyle(
                                  color: AppColors.danger,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                detail.motifRejet!,
                                style: TextStyle(
                                  color: isDark ? Colors.red.shade200 : const Color(0xFF7F1D1D),
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // 2. Lecteur Audio (mis en avant s'il existe)
                if (hasAudio) ...[
                  const SizedBox(height: 14),
                  _buildModernCard(
                    isDark: isDark,
                    icon: Icons.graphic_eq_rounded,
                    title: 'Témoignage vocal enregistré',
                    child: PlanteAudioPlayerCard(
                      audioUrl: detail.audioUrl!,
                      title: 'Enregistrement de terrain',
                      subtitle: detail.sourceNomComplet ?? ' Informateur local',
                    ),
                  ),
                ],

                // 3. Description de la mission
                if (detail.description != null && detail.description!.trim().isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _buildModernCard(
                    isDark: isDark,
                    icon: Icons.description_outlined,
                    title: 'Description de la mission',
                    child: Text(
                      detail.description!,
                      style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body).copyWith(
                        height: 1.5,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],

                // 4. Savoirs ethnobotaniques (si présents dans le récapitulatif)
                if (recap != null &&
                    (recap.usagesRapportes.isNotEmpty ||
                        recap.partiesUtilisees.isNotEmpty ||
                        recap.modesPreparation.isNotEmpty ||
                        recap.maladiesAssociees.isNotEmpty)) ...[
                  const SizedBox(height: 14),
                  _buildEthnobotanicalCard(isDark: isDark, recap: recap),
                ],

                // 5. Source / Praticien interrogé
                const SizedBox(height: 14),
                _buildSourceCard(isDark: isDark, detail: detail),

                // 6. Territoire & Géolocalisation
                const SizedBox(height: 14),
                _buildLocationCard(isDark: isDark, detail: detail),

                // 7. Actions (Modifier / Soumettre)
                if (detail.modifiable || detail.soumissible) ...[
                  const SizedBox(height: 24),
                  _buildActionButtons(context, ref, detail, recap),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroHeaderCard({
    required bool isDark,
    required AgentCollecteDetailModel detail,
    required AgentCollecteRecapitulatifModel? recap,
    required _StatusStyle statusStyle,
    required bool hasPhoto,
  }) {
    final planteTitle = recap?.planteNomScientifique ?? 'Échantillon ethnobotanique';
    final dateFormatted = _formatDate(detail.dateCollecte);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasPhoto)
            Stack(
              children: [
                SizedBox(
                  height: 210,
                  width: double.infinity,
                  child: Image.network(
                    ApiEndpoints.resolveMediaUrl(detail.photoUrl),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      child: const Center(
                        child: Icon(
                          Icons.local_florist_rounded,
                          size: 56,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.25),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.65),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: _buildStatusPill(statusStyle),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        planteTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      if (dateFormatted.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 13,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Collectée le $dateFormatted',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            )
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          planteTitle,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            fontStyle: FontStyle.italic,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                        if (dateFormatted.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Collectée le $dateFormatted',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusPill(statusStyle),
                ],
              ),
            ),
          if (recap != null && recap.nomsVernaculaires.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: recap.nomsVernaculaires.map((nom) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.translate_rounded,
                          size: 13,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          nom,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(_StatusStyle style) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: style.bgColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 15, color: style.color),
          const SizedBox(width: 5),
          Text(
            style.label,
            style: TextStyle(
              color: style.color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEthnobotanicalCard({
    required bool isDark,
    required AgentCollecteRecapitulatifModel recap,
  }) {
    return _buildModernCard(
      isDark: isDark,
      icon: Icons.menu_book_rounded,
      title: 'Savoirs & Usages thérapeutiques',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recap.maladiesAssociees.isNotEmpty) ...[
            _buildSubLabel(isDark, 'Maladies / affections traitées'),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: recap.maladiesAssociees.map((m) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    m,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF92400E),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
          if (recap.partiesUtilisees.isNotEmpty) ...[
            _buildInfoRow(
              isDark: isDark,
              icon: Icons.grass_rounded,
              label: 'Parties utilisées',
              value: recap.partiesUtilisees.join(', '),
            ),
            const SizedBox(height: 10),
          ],
          if (recap.usagesRapportes.isNotEmpty) ...[
            _buildInfoRow(
              isDark: isDark,
              icon: Icons.healing_rounded,
              label: 'Usage rapporté',
              value: recap.usagesRapportes.join('\n'),
            ),
            const SizedBox(height: 10),
          ],
          if (recap.modesPreparation.isNotEmpty) ...[
            _buildInfoRow(
              isDark: isDark,
              icon: Icons.science_outlined,
              label: 'Préparation & posologie',
              value: recap.modesPreparation.join('\n'),
            ),
          ],
          if (recap.precautions.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildInfoRow(
              isDark: isDark,
              icon: Icons.warning_amber_rounded,
              label: 'Précautions',
              value: recap.precautions.join('\n'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSourceCard({
    required bool isDark,
    required AgentCollecteDetailModel detail,
  }) {
    final nom = detail.sourceNomComplet ?? 'Non spécifié';
    final initiales = nom.trim().isNotEmpty
        ? nom
            .trim()
            .split(RegExp(r'\s+'))
            .take(2)
            .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
            .join()
        : '?';

    return _buildModernCard(
      isDark: isDark,
      icon: Icons.person_pin_rounded,
      title: 'Source / Praticien interrogé',
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.75),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              initiales,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nom,
                  style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                if (detail.sourceSpecialite != null &&
                    detail.sourceSpecialite!.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    detail.sourceSpecialite!,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                    ),
                  ),
                ],
                if (detail.sourceTelephone != null &&
                    detail.sourceTelephone!.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 14,
                        color: AppColors.primary.withValues(alpha: 0.9),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        detail.sourceTelephone!,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard({
    required bool isDark,
    required AgentCollecteDetailModel detail,
  }) {
    final hasGps = detail.latitude != null && detail.longitude != null;

    return _buildModernCard(
      isDark: isDark,
      icon: Icons.location_on_rounded,
      title: 'Territoire & Géolocalisation',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (detail.region != null && detail.region!.isNotEmpty)
                _buildLocationBadge(
                  isDark: isDark,
                  label: 'Région',
                  value: detail.region!,
                ),
              if (detail.cercle != null && detail.cercle!.isNotEmpty)
                _buildLocationBadge(
                  isDark: isDark,
                  label: 'Cercle',
                  value: detail.cercle!,
                ),
              if (detail.commune != null && detail.commune!.isNotEmpty)
                _buildLocationBadge(
                  isDark: isDark,
                  label: 'Commune',
                  value: detail.commune!,
                ),
            ],
          ),
          if (detail.localite != null && detail.localite!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.holiday_village_outlined,
                  size: 16,
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Localité / Village : ${detail.localite!}',
                    style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body).copyWith(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (hasGps) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.gps_fixed_rounded,
                    size: 15,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'GPS : ${detail.latitude!.toStringAsFixed(4)}, ${detail.longitude!.toStringAsFixed(4)}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationBadge({
    required bool isDark,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    AgentCollecteDetailModel detail,
    AgentCollecteRecapitulatifModel? recap,
  ) {
    final canSubmit = recap == null ? detail.soumissible : recap.conformePourSoumission;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (detail.modifiable)
          OutlinedButton.icon(
            onPressed: () {
              ref.read(nouvelleCollecteWizardProvider.notifier).loadFromDetail(detail, recap);
              context.push(RouteNames.agentNouvelleCollectePath);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1.4),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.edit_outlined, size: 19),
            label: const Text(
              'Compléter ou modifier la fiche',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        if (detail.modifiable && canSubmit) const SizedBox(height: 10),
        if (canSubmit)
          ElevatedButton.icon(
            onPressed: () async {
              try {
                final api = ref.read(agentApiServiceProvider);
                await api.soumettreCollecte(detail.id);
                ref.invalidate(agentCollecteDetailProvider(collecteId));
                ref.invalidate(agentCollecteRecapitulatifProvider(collecteId));
                ref.invalidate(agentCollectesListProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Collecte soumise pour validation avec succès.'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur : $e'),
                      backgroundColor: AppColors.danger,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.send_rounded, size: 18),
            label: const Text(
              'Soumettre au comité de validation',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
      ],
    );
  }

  Widget _buildModernCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(icon, size: 14, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildSubLabel(bool isDark, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
      ),
    );
  }

  Widget _buildInfoRow({
    required bool isDark,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            icon,
            size: 16,
            color: AppColors.primary.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body).copyWith(
                  fontSize: 13.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusStyle {
  final String label;
  final Color color;
  final Color bgColor;
  final IconData icon;

  const _StatusStyle({
    required this.label,
    required this.color,
    required this.bgColor,
    required this.icon,
  });
}
