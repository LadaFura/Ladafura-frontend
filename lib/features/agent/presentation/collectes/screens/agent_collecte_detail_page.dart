import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ladafura_frontend_flutter/core/constants/api_endpoints.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_text_styles.dart';
import 'package:ladafura_frontend_flutter/core/network/error_handler.dart';
import 'package:ladafura_frontend_flutter/core/routing/route_names.dart';
import 'package:ladafura_frontend_flutter/features/agent/models/agent_collecte_detail_model.dart';
import 'package:ladafura_frontend_flutter/features/agent/models/agent_recapitulatif_model.dart';
import 'package:ladafura_frontend_flutter/features/agent/providers/agent_providers.dart';
import 'package:ladafura_frontend_flutter/features/plantes/presentation/widgets/plante_audio_player_card.dart';
import 'package:ladafura_frontend_flutter/shared/widgets/formatted_html_text.dart';

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

    final detail = detailAsync.valueOrNull;
    final canSubmit = detail != null &&
        detail.soumissible &&
        (recap == null || recap.conformePourSoumission);
    final hasBottomActions = detail != null && (detail.modifiable || canSubmit);

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
        actions: [
          if (detail != null && detail.modifiable)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton.tonal(
                onPressed: () {
                  ref
                      .read(nouvelleCollecteWizardProvider.notifier)
                      .loadFromDetail(detail, recap);
                  context.push(RouteNames.agentNouvelleCollectePath);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  foregroundColor: AppColors.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                ),
                child: const Text(
                  'Modifier',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: hasBottomActions
          ? _buildBottomActionBar(
              context: context,
              ref: ref,
              detail: detail,
              recap: recap,
              isDark: isDark,
              canSubmit: canSubmit,
            )
          : null,
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

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.invalidate(agentCollecteDetailProvider(collecteId));
              ref.invalidate(agentCollecteRecapitulatifProvider(collecteId));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Carte En-tête Hero (Photo + Plante + Statut + Date)
                _buildHeroHeaderCard(
                  context: context,
                  ref: ref,
                  isDark: isDark,
                  detail: detail,
                  recap: recap,
                  statusStyle: statusStyle,
                  hasPhoto: hasPhoto,
                ),

                // Bannière informative si validée ou soumise
                if (detail.statut.toUpperCase() == 'VALIDEE') ...[
                  const SizedBox(height: 14),
                  _buildStatusNoticeCard(
                    isDark: isDark,
                    icon: Icons.verified_rounded,
                    color: Colors.green,
                    title: 'Fiche de collecte validée & intégrée',
                    message:
                        'Cette collecte a été approuvée par le comité scientifique et intégrée au patrimoine botanique officiel. Elle n\'est plus modifiable.',
                  ),
                ] else if (detail.statut.toUpperCase() == 'SOUMISE' ||
                    detail.statut.toUpperCase() == 'EN_EXAMEN') ...[
                  const SizedBox(height: 14),
                  _buildStatusNoticeCard(
                    isDark: isDark,
                    icon: Icons.hourglass_top_rounded,
                    color: Colors.amber.shade800,
                    title: 'Examen en cours par le comité',
                    message:
                        'Cette fiche de collecte a été transmise pour modération. Toute modification est suspendue pendant son examen.',
                  ),
                ],

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

                // 2. Lecteur Audio (ou incitation à enregistrer si absent)
                if (hasAudio) ...[
                  const SizedBox(height: 14),
                  _buildModernCard(
                    isDark: isDark,
                    icon: Icons.graphic_eq_rounded,
                    title: 'Témoignage vocal enregistré',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PlanteAudioPlayerCard(
                          audioUrl: detail.audioUrl!,
                          title: 'Enregistrement de terrain',
                          subtitle: detail.sourceNomComplet ?? ' Informateur local',
                        ),
                        if (detail.statut.toUpperCase() != 'VALIDEE') ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => _handlePickAndUploadAudio(context, ref, detail.id),
                              child: const Text('Remplacer l\'audio'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ] else if (detail.statut.toUpperCase() != 'VALIDEE') ...[
                  const SizedBox(height: 14),
                  _buildModernCard(
                    isDark: isDark,
                    icon: Icons.mic_none_rounded,
                    title: 'Témoignage vocal (Audio)',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aucun enregistrement vocal n\'a encore été joint à cette fiche de collecte. Vous pouvez en importer ou enregistrer un maintenant.',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () => _handlePickAndUploadAudio(context, ref, detail.id),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
                          ),
                          child: const Text('Ajouter un enregistrement audio'),
                        ),
                      ],
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
                    child: _ExpandableDescriptionText(
                      text: detail.description!,
                      isDark: isDark,
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

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
        },
      ),
    );
  }

  Widget _buildStatusNoticeCard({
    required bool isDark,
    required IconData icon,
    required Color color,
    required String title,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : const Color(0xFF1F2937),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeaderCard({
    required BuildContext context,
    required WidgetRef ref,
    required bool isDark,
    required AgentCollecteDetailModel detail,
    required AgentCollecteRecapitulatifModel? recap,
    required _StatusStyle statusStyle,
    required bool hasPhoto,
  }) {
    final planteTitle = recap?.planteNomScientifique ?? 'Échantillon ethnobotanique';
    final dateFormatted = _formatDate(detail.dateCollecte);
    final canModifyMedia = detail.statut.toUpperCase() != 'VALIDEE';

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
                  child: CachedNetworkImage(
                    imageUrl: ApiEndpoints.resolveMediaUrl(detail.photoUrl),
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      child: const Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
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
                if (canModifyMedia)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Material(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => _handlePickAndUploadPhoto(context, ref, detail.id),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.camera_alt_outlined, size: 14, color: Colors.white),
                              SizedBox(width: 5),
                              Text(
                                'Changer photo',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
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
          else ...[
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
            if (canModifyMedia)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: OutlinedButton(
                  onPressed: () => _handlePickAndUploadPhoto(context, ref, detail.id),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  ),
                  child: const Text(
                    'Ajouter la photo du spécimen',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ],
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
                  Text(
                    'Tél : ${detail.sourceTelephone!}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
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
            Text(
              'Localité / Village : ${detail.localite!}',
              style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body).copyWith(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
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
              child: Text(
                'GPS : ${detail.latitude!.toStringAsFixed(4)}, ${detail.longitude!.toStringAsFixed(4)}',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
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

  Widget _buildBottomActionBar({
    required BuildContext context,
    required WidgetRef ref,
    required AgentCollecteDetailModel detail,
    required AgentCollecteRecapitulatifModel? recap,
    required bool isDark,
    required bool canSubmit,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space16,
        vertical: AppDimensions.space12,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.inputBorder,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: (detail.modifiable && canSubmit)
            ? Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () {
                          ref
                              .read(nouvelleCollecteWizardProvider.notifier)
                              .loadFromDetail(detail, recap);
                          context.push(RouteNames.agentNouvelleCollectePath);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                          side: BorderSide(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.inputBorder,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Modifier',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            final api = ref.read(agentApiServiceProvider);
                            await api.soumettreCollecte(detail.id);
                            ref.invalidate(
                                agentCollecteDetailProvider(collecteId));
                            ref.invalidate(
                                agentCollecteRecapitulatifProvider(collecteId));
                            ref.invalidate(agentCollectesListProvider);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Collecte soumise pour validation avec succès.',
                                  ),
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              final appError = ErrorHandler.handle(e);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(appError.message),
                                  backgroundColor: AppColors.danger,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Soumettre',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (detail.modifiable)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          ref
                              .read(nouvelleCollecteWizardProvider.notifier)
                              .loadFromDetail(detail, recap);
                          context.push(RouteNames.agentNouvelleCollectePath);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Modifier la fiche de collecte',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  if (canSubmit)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            final api = ref.read(agentApiServiceProvider);
                            await api.soumettreCollecte(detail.id);
                            ref.invalidate(
                                agentCollecteDetailProvider(collecteId));
                            ref.invalidate(
                                agentCollecteRecapitulatifProvider(collecteId));
                            ref.invalidate(agentCollectesListProvider);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Collecte soumise pour validation avec succès.',
                                  ),
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              final appError = ErrorHandler.handle(e);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(appError.message),
                                  backgroundColor: AppColors.danger,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Soumettre au comité de validation',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
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
    IconData? icon,
    required String label,
    required String value,
  }) {
    return Column(
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
        FormattedHtmlText(
          value,
          style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body).copyWith(
            fontSize: 13.5,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Future<void> _handlePickAndUploadPhoto(
    BuildContext context,
    WidgetRef ref,
    int collecteId,
  ) async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Photo du spécimen',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                title: const Text('Prendre une photo'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
                title: const Text('Choisir depuis la galerie'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    try {
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
      );
      if (picked == null) return;

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text('Envoi de la photo en cours...'),
            ],
          ),
          duration: Duration(seconds: 15),
        ),
      );

      final api = ref.read(agentApiServiceProvider);
      await api.uploadPhoto(collecteId: collecteId, file: File(picked.path));

      ref.invalidate(agentCollecteDetailProvider(collecteId));
      ref.invalidate(agentCollecteRecapitulatifProvider(collecteId));
      ref.invalidate(agentCollectesListProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo du spécimen enregistrée avec succès.'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        final appError = ErrorHandler.handle(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur envoi photo : ${appError.message}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _handlePickAndUploadAudio(
    BuildContext context,
    WidgetRef ref,
    int collecteId,
  ) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'm4a', 'wav', 'aac', 'ogg'],
      );
      if (result.isEmpty || result.first.path == null) {
        return;
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text('Envoi de l\'enregistrement audio...'),
            ],
          ),
          duration: Duration(seconds: 15),
        ),
      );

      final api = ref.read(agentApiServiceProvider);
      await api.uploadAudio(
        collecteId: collecteId,
        file: File(result.first.path!),
      );

      ref.invalidate(agentCollecteDetailProvider(collecteId));
      ref.invalidate(agentCollecteRecapitulatifProvider(collecteId));
      ref.invalidate(agentCollectesListProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Témoignage audio enregistré avec succès.'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        final appError = ErrorHandler.handle(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur envoi audio : ${appError.message}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
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

class _ExpandableDescriptionText extends StatefulWidget {
  final String text;
  final bool isDark;

  const _ExpandableDescriptionText({
    required this.text,
    required this.isDark,
  });

  @override
  State<_ExpandableDescriptionText> createState() => _ExpandableDescriptionTextState();
}

class _ExpandableDescriptionTextState extends State<_ExpandableDescriptionText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final plainText = FormattedHtmlText.stripHtml(widget.text);
    final isLong = plainText.length > 200 || plainText.split('\n').length > 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormattedHtmlText(
          widget.text,
          maxLines: _isExpanded ? null : 4,
          overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: (widget.isDark ? AppTextStyles.bodyDark : AppTextStyles.body).copyWith(
            height: 1.5,
            fontSize: 14,
          ),
        ),
        if (isLong) ...[
          const SizedBox(height: 6),
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isExpanded ? 'Voir moins' : 'Lire toute la description',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

