import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_text_styles.dart';
import 'package:ladafura_frontend_flutter/features/agent/providers/agent_providers.dart';

/// Écran de consultation détaillée d'une fiche de collecte de terrain.
class AgentCollecteDetailPage extends ConsumerWidget {
  final int collecteId;

  const AgentCollecteDetailPage({super.key, required this.collecteId});

  Color _getStatusColor(String statut) {
    switch (statut.toUpperCase()) {
      case 'VALIDEE':
        return Colors.green;
      case 'REJETEE':
        return AppColors.danger;
      case 'SOUMISE':
      case 'EN_EXAMEN':
        return Colors.amber.shade800;
      case 'BROUILLON':
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final detailAsync = ref.watch(agentCollecteDetailProvider(collecteId));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.surface,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Détail Collecte #$collecteId',
          style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.orange),
              const SizedBox(height: 12),
              Text('Erreur de chargement: $err'),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(agentCollecteDetailProvider(collecteId)),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
        data: (detail) {
          final statusColor = _getStatusColor(detail.statut);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Bandeau Statut & Modération
                Container(
                  padding: const EdgeInsets.all(AppDimensions.space16),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.shield_outlined, color: statusColor, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'STATUT : ${detail.statut.toUpperCase()}',
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            if (detail.motifRejet != null &&
                                detail.motifRejet!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Motif du retour : ${detail.motifRejet!}',
                                style: const TextStyle(
                                  color: AppColors.danger,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.space16),

                // Carte Description
                if (detail.description != null &&
                    detail.description!.isNotEmpty) ...[
                  _buildSection(
                    isDark: isDark,
                    title: 'Description de la mission',
                    icon: Icons.notes_rounded,
                    child: Text(
                      detail.description!,
                      style: isDark ? AppTextStyles.bodyDark : AppTextStyles.body,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Carte Source
                _buildSection(
                  isDark: isDark,
                  title: 'Source / Praticien interrogé',
                  icon: Icons.person_pin_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail.sourceNomComplet ?? 'Non spécifié',
                        style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (detail.sourceSpecialite != null)
                        Text(
                          detail.sourceSpecialite!,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                          ),
                        ),
                      if (detail.sourceTelephone != null)
                        Text(
                          'Contact : ${detail.sourceTelephone!}',
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Carte Localisation
                _buildSection(
                  isDark: isDark,
                  title: 'Territoire & Géolocalisation',
                  icon: Icons.location_on_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Région : ${detail.region ?? "Non renseignée"}'
                        '${detail.cercle != null ? " • Cercle : ${detail.cercle!}" : ""}'
                        '${detail.commune != null ? " • Commune : ${detail.commune!}" : ""}',
                        style: isDark ? AppTextStyles.bodyDark : AppTextStyles.body,
                      ),
                      if (detail.localite != null)
                        Text(
                          'Village / Hameau : ${detail.localite!}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      if (detail.latitude != null && detail.longitude != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.gps_fixed, size: 14, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              'GPS : ${detail.latitude!.toStringAsFixed(4)}, ${detail.longitude!.toStringAsFixed(4)}',
                              style: const TextStyle(fontSize: 12, color: Colors.green),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Médias
                if (detail.photoUrl != null || detail.audioUrl != null) ...[
                  _buildSection(
                    isDark: isDark,
                    title: 'Médias enregistrés',
                    icon: Icons.perm_media_rounded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (detail.photoUrl != null)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.photo, color: AppColors.primary, size: 18),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text('Photo de l’échantillon disponible', style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                          ),
                        if (detail.audioUrl != null)
                          const Row(
                            children: [
                              Icon(Icons.mic, color: Colors.green, size: 18),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text('Enregistrement audio joint', style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Action de soumission si modifiable
                if (detail.modifiable || detail.soumissible)
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        final api = ref.read(agentApiServiceProvider);
                        await api.soumettreCollecte(detail.id);
                        ref.invalidate(agentCollecteDetailProvider(collecteId));
                        ref.invalidate(agentCollectesListProvider);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Collecte soumise pour validation avec succès.'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erreur : $e'), backgroundColor: AppColors.danger),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Soumettre au comité de validation'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required bool isDark,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.inputBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          child,
        ],
      ),
    );
  }
}
